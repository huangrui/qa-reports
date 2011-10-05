#
# This file is part of meego-test-reports
#
# Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
#
# Authors: Sami Hangaslammi <sami.hangaslammi@leonidasoy.fi>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License
# version 2.1 as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA
#

require 'testreport'
require 'csv'
require 'trimmer'
require 'report_parser'
require 'validation/date_time_validator'
require 'file_storage'

require 'graph'
require 'nft'
require 'lib/array_nested_hashing'

#noinspection Rails3Deprecated
class MeegoTestSession < ActiveRecord::Base
  include Trimmer
  include Graph
  include MeasurementUtils
  include CacheHelper

  belongs_to :author, :class_name => "User"
  belongs_to :editor, :class_name => "User"
  belongs_to :release

  has_many :features,         :dependent => :destroy, :order => "id DESC"
  has_many :meego_test_cases, :autosave => false,     :order => "id DESC"
  has_many :test_cases,       :class_name => "MeegoTestCase", :autosave => false,     :order => "id DESC"
  has_many :passed,           :class_name => "MeegoTestCase", :conditions => { :result => MeegoTestCase::PASS     }
  has_many :failed,           :class_name => "MeegoTestCase", :conditions => { :result => MeegoTestCase::FAIL     }
  has_many :na,               :class_name => "MeegoTestCase", :conditions => { :result => MeegoTestCase::NA       }
  has_many :measured,         :class_name => "MeegoTestCase", :conditions => { :result => MeegoTestCase::MEASURED }

  has_many :result_files,     :class_name => 'FileAttachment', :as => :attachable, :dependent => :destroy, :conditions => {:attachment_type => 'result_file'}
  has_many :attachments,      :class_name => 'FileAttachment', :as => :attachable, :dependent => :destroy, :conditions => {:attachment_type => 'attachment'}

  validates_presence_of :title, :target, :testset, :product
  validates_presence_of :result_files
  validates_presence_of :author
  validates_presence_of :release
  validates             :tested_at, :date_time => true
  validate              :validate_profile_testset_and_product

  accepts_nested_attributes_for :features, :result_files

  scope :published,  where(:published => true)
  scope :release,    lambda { |release| published.joins(:release).where(:releases => {:name => release}) }
  scope :profile,    lambda { |profile| published.where(:target => profile.downcase) }
  scope :testset,    lambda { |testset| published.where(:testset => testset.downcase) }
  scope :product_is, lambda { |product| published.where(:product => product.downcase) }

  include ReportSummary

  def meego_test_session
    self
  end

  def self.latest
    published.order(:tested_at).last
  end

  def month
    @month ||= tested_at.strftime("%B %Y")
  end


  def self.fetch_fully(id)
    find(id, :include =>
         {:features =>
           {:meego_test_cases => [:measurements, :serial_measurements, :attachment, :feature, :meego_test_session]}
         })
  end

  def self.fetch_for_comparison(id)
    find(id, :include => {:meego_test_cases => [:feature, :meego_test_session]})
  end

  def self.testsets
    published.select("DISTINCT testset").order("testset").map(&:testset)
  end

  def self.popular_testsets(limit=3)
    published.select("testset").order("COUNT(testset) DESC").group(:testset).map(&:testset)
  end

  def self.products
    published.select("DISTINCT product as product").order("product").map(&:product)
  end

  def self.popular_products(limit=3)
    published.select("product as product").order("COUNT(product) DESC").
      group(:product).limit(limit).map(&:product)
  end

  def target=(target)
    target = target.try(:downcase)
    write_attribute(:target, target)
  end

  def target
    read_attribute(:target).try(:capitalize)
  end

  def self.popular_build_ids(limit=3)
    published.select("build_id as build_id").order("COUNT(build_id) DESC").
      group(:build_id).limit(limit).map { |row| row.build_id.humanize }
  end

  def prev_summary
    prev_session
  end

  def self.load_case_counts_for_reports!(reports)
    result_counts = MeegoTestCase.select([:meego_test_session_id, :result, :count]).
      where(:meego_test_session_id => reports).group(:meego_test_session_id, :result).count(:result)

    reports.map! do |report|
      report.total_passed   = result_counts[[report.id, MeegoTestCase::PASS]]
      report.total_failed   = result_counts[[report.id, MeegoTestCase::FAIL]]
      report.total_na       = result_counts[[report.id, MeegoTestCase::NA]]
      report.total_measured = result_counts[[report.id, MeegoTestCase::MEASURED]]
      report.total_cases    = report.total_passed + report.total_failed + report.total_na + report.total_measured
      report
    end
  end

  ###############################################
  # Test session navigation                     #
  ###############################################
  def prev_session
    return @prev_session unless @prev_session.nil? and @has_prev.nil?
    tested = tested_at || Time.now
    created = created_at || Time.now

    @prev_session = MeegoTestSession.find(:first, :conditions => [
        "(tested_at < ? OR tested_at = ? AND created_at < ?) AND target = ? AND testset = ? AND product = ? AND published = ? AND release_id = ?", tested, tested, created, target.downcase, testset.downcase, product.downcase, true, release_id
    ],
                          :order => "tested_at DESC, created_at DESC", :include =>
         [{:features => :meego_test_cases}, {:meego_test_cases => :feature}])

    @has_prev = !@prev_session.nil?
    @prev_session
  end

  def next_session
    return @next_session unless @next_session.nil? and @has_next.nil?
    @next_session = MeegoTestSession.find(:first, :conditions => [
        "(tested_at > ? OR tested_at = ? AND created_at > ?) AND target = ? AND testset = ? AND product = ? AND published = ? AND release_id = ?", tested_at, tested_at, created_at, target.downcase, testset.downcase, product.downcase, true, release_id
    ],
                          :order => "tested_at ASC, created_at ASC", :include =>
         [{:features => :meego_test_cases}, {:meego_test_cases => :feature}])

    @has_next = !@next_session.nil?
    @next_session
  end

  ###############################################
  # Utility methods for viewing a report        #
  ###############################################
  def formatted_date
    tested_at ? tested_at.strftime("%Y-%m-%d") : 'n/a'
  end

  def nft_sets
    features.select &:has_nft?
  end

  def non_nft_features
    features.select &:has_non_nft?
  end

  def test_case_by_name(feature_key, name)
    @test_case_hash ||= meego_test_cases.to_nested_hash [:feature_key, :name]
    @test_case_hash[feature_key][name] unless @test_case_hash[feature_key].nil?
  end

  ###############################################
  # Chart visualization methods                 #
  ###############################################
  def summary_data
    data = Graph::Data.new
    data.passed    = passed   = []
    data.failed    = failed   = []
    data.na        = na       = []
    data.measured  = measured = []
    data.labels    = labels   = []

    prev = prev_session
    if prev
      pp = prev.prev_session
      if pp
        passed    << pp.total_passed
        failed    << pp.total_failed
        na        << pp.total_na
        measured  << pp.total_measured
        labels    << pp.formatted_date
      else
        passed    << 0
        failed    << 0
        na        << 0
        measured  << 0
        labels    << ""
      end

      passed    << prev.total_passed
      failed    << prev.total_failed
      na        << prev.total_na
      measured  << prev.total_measured
      labels    << prev.formatted_date
    else
      passed    << 0
      failed    << 0
      na        << 0
      measured  << 0
      labels    << ""
    end

    passed    << total_passed
    failed    << total_failed
    na        << total_na
    measured  << total_measured
    labels    << "Current"

    data
  end

  def max_feature_cases
    features.map{|item| item.total_cases}.max
  end

  def non_empty_features
    features.select{|feature| feature.total_cases > 0}
  end

  def small_graph_img_tag(max_cases)
    html_graph(total_passed, total_failed, total_na, max_cases)
  end

  ###############################################
  # Text data html formatting                   #
  ###############################################
  def objective_html
    txt = objective_txt
    if txt == ""
      "No objective filled in yet"
    else
      MeegoTestReport::format_txt(txt)
    end
  end

  def tested_at_html
    tested_at.strftime("%Y-%m-%d")
  end

  def tested_at_txt
    tested_at.strftime("%Y-%m-%d")
  end

  def build_html
    txt = build_txt
    if txt == ""
      "No build details filled in yet"
    else
      MeegoTestReport::format_txt(txt)
    end
  end

  def environment_html
    txt = environment_txt
    if txt == ""
      "No environment description filled in yet"
    else
      MeegoTestReport::format_txt(txt)
    end
  end

  def qa_summary_html
    txt = qa_summary_txt
    if txt == ""
      "No quality summary filled in yet"
    else
      MeegoTestReport::format_txt(txt)
    end
  end

  def issue_summary_html
    txt = issue_summary_txt
    if txt == ""
      "No issue summary filled in yet"
    else
      MeegoTestReport::format_txt(txt)
    end
  end

  def validate_profile_testset_and_product
    errors.add :target, "Incorrect target '#{target}'. Valid ones are #{TargetLabel.labels.join(',')}." if target.present? and not TargetLabel.find_by_normalized(target.downcase)

    # \A and \z instead of ^ and $ cause multiline strings to fail validation.
    # And for the record: at least these characters break the navigation:
    # . % \ / (yes, dot is there as well for some oddball reason)
    allowed = /\A[\w\ \-:;,\(\)]+\z/

    errors.add :testset, "Incorrect test set. Please use only characters A-Z, a-z, 0-9, spaces and these special characters: , : ; - _ ( )" unless testset.match(allowed)
    errors.add :product, "Incorrect product. Please use only characters A-Z, a-z, 0-9, spaces and these special characters: , : ; - _ ( )"  unless product.match(allowed)
  end

  def generate_defaults!
    time                 = tested_at || Time.now
    self.title           ||= "%s Test Report: %s %s %s" % [target, product_label, testset_label, time.strftime('%Y-%m-%d')]
    self.environment_txt = "* Product: " + product if self.environment_txt.empty?
  end

  def format_date
    tested_at.strftime("%d.%m")
  end

  def format_year
    tested_at.strftime("%Y")
  end

  RESULT_NAMES = {"fail"     => MeegoTestCase::FAIL,
                  "na"       => MeegoTestCase::NA,
                  "pass"     => MeegoTestCase::PASS,
                  "measured" => MeegoTestCase::MEASURED}

  #TODO: move to test case?
  def self.map_result(result)
    RESULT_NAMES[result.downcase] || MeegoTestCase::NA
  end

  def self.result_as_string(result)
    RESULT_NAMES.invert[result] || RESULT_NAMES.invert(MeegoTestCase::NA)
  end



  def update_report_result(user, params, published = true)
    tmp = ReportFactory.new.build(params)
    parsing_errors = tmp.errors[:result_files]

    user.update_attribute(:default_target, self.target) if self.target.present?
    self.editor    = user
    self.published = published

    if !parsing_errors.empty?
      return parsing_errors.join(',')
    else
      @result_files = tmp.result_files
      self.features.clear
      self.meego_test_cases.clear
      tmp.features.each do |feature|
        feature.meego_test_cases.each { |tc| tc.meego_test_session = self }
      end
      self.features = tmp.features
      self.meego_test_cases = tmp.meego_test_cases
      return nil
    end
  end

end
