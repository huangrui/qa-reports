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

require 'resultparser'
require 'testreport'
require 'csv'
require 'trimmer'
require 'report_parser'
require 'validation/date_time_validator'
require 'will_paginate'
require 'file_storage'

require 'graph'
require 'nft'

#noinspection Rails3Deprecated
class MeegoTestSession < ActiveRecord::Base
  include Trimmer
  include Graph
  include MeasurementUtils
  include CacheHelper

  attr_accessor :uploaded_files

  has_many :meego_test_sets, :dependent => :destroy
  has_many :meego_test_cases
  has_many :test_result_files, :dependent => :destroy
  has_many :passed, :class_name => "MeegoTestCase", :conditions => "result = #{MeegoTestCase::PASS}"
  has_many :failed, :class_name => "MeegoTestCase", :conditions => "result = #{MeegoTestCase::FAIL}"
  has_many :na, :class_name => "MeegoTestCase", :conditions => "result = #{MeegoTestCase::NA}"

  belongs_to :author, :class_name => "User"
  belongs_to :editor, :class_name => "User"

  belongs_to :version_label, :class_name => "VersionLabel", :foreign_key => "version_label_id"

  validates_presence_of :title, :target, :testtype, :hardware
  validates_presence_of :uploaded_files, :on => :create

  validates :tested_at, :date_time => true

  validate :save_uploaded_files, :on => :create

  validate :validate_labels
  validate :validate_type_hw

  before_save :force_testtype_hardware_names

  after_destroy :remove_uploaded_files

  scope :published, where(:published => true)
  scope :release, lambda { |release| published.joins(:version_label).where(:version_labels => {:normalized => release.downcase}) }
  scope :profile, lambda { |profile| published.where(:target => profile.downcase) }
  scope :test_type, lambda { |test_type| published.where(:testtype => test_type.downcase) }
  scope :hardware, lambda { |hardware| published.where(:hardware => hardware.downcase) }

  RESULT_FILES_DIR = "public/reports"
  INVALID_RESULTS_DIR = "public/reports/invalid_files"

  include ReportSummary

  def self.latest
    published.order(:tested_at).last
  end

  def month
    @month ||= tested_at.strftime("%B %Y")
  end


  def self.fetch_fully(id)
    find(id, :include =>
         {:meego_test_sets =>
           {:meego_test_cases => [:measurements, :serial_measurements, :meego_test_case_attachments, :meego_test_set, :meego_test_session]}
         })
  end

  def self.testtypes
    published.select("DISTINCT testtype").order("testtype").map(&:testtype)
  end

  def self.popular_testtypes(limit=3)
    published.select("testtype").order("COUNT(testtype) DESC").group(:testtype).map(&:testtype)
  end

  def self.hardwares
    published.select("DISTINCT hardware as hardware").order("hardware").map(&:hardware)
  end

  def self.popular_hardwares(limit=3)
    published.select("hardware as hardware").order("COUNT(hardware) DESC").
      group(:hardware).limit(limit).map(&:hardware)
  end

  def target=(target)
    target = target.try(:downcase)
    write_attribute(:target, target)
  end

  def target
    read_attribute(:target).try(:capitalize)
  end

  def build_id_txt=(build_id)
    write_attribute(:build_id, build_id)
  end

  def build_id_txt
    s = read_attribute(:build_id)
  end

  def self.popular_build_ids(limit=3)
    published.select("build_id as build_id").order("COUNT(build_id) DESC").
      group(:build_id).limit(limit).map { |row| row.build_id.humanize }
  end

  def prev_summary
    prev_session
  end

  def has_nft?
    return has_nft
  end

  def has_non_nft?
    return has_ft
  end

  def raw_result_files
    FileStorage.new(dir="public/reports", baseurl="/reports/").list_report_files(self)
  end

  def self.import(attributes, files, user)
    attr             = attributes.merge!({:uploaded_files => files})
    result           = MeegoTestSession.new(attr)
    result.tested_at = result.tested_at || Time.now
    result.import_report(user, true)
    result.save!
    result
  end

  def self.targets
    TargetLabel.find(:all, :order => "sort_order ASC").map &:label
  end

  def self.release_versions
    VersionLabel.find(:all, :order => "sort_order ASC").map &:label
  end

  def self.latest_release_version
    release_versions[0]
  end

  def self.filters_exist?(target, testtype, hardware)
    return true if target.blank? and testtype.blank? and hardware.blank?

    filters_exist = false

    if target.present?
      filters_exist = find_by_target(target.downcase).present?

      if testtype.present?
        filters_exist &= find_by_testtype(testtype.downcase).present?
      end

      if testtype.present? && hardware.present?
        filters_exist &= find_by_hardware(hardware.downcase).present?
      end
    end

    return filters_exist
  end

  def self.all_lowercase(options = {})
    options[:conditions].each do |key, value|
      options[:conditions][key] = value.downcase if value.kind_of? String
    end
    all(options)
  end

  class << self
    def by_release_version_target_test_type_product(release_version, target, testtype, hardware, order_by = "tested_at DESC, id DESC", limit = nil)
      target    = target.downcase
      testtype  = testtype.downcase
      hardware = hardware.downcase
      published.where("version_labels.normalized" => release_version.downcase, :target => target, :testtype => testtype, :hardware => hardware).joins(:version_label).order(order_by).limit(limit)
    end

    def published_by_release_version_target_test_type(release_version, target, testtype, order_by = "tested_at DESC, id DESC", limit = nil)
      target   = target.downcase
      testtype = testtype.downcase
      published.where("version_labels.normalized" => release_version.downcase, :target => target, :testtype => testtype).joins(:version_label).order(order_by).limit(limit)
    end

    def published_hwversion_by_release_version_target_test_type(release_version, target, testtype)
      target   = target.downcase
      testtype = testtype.downcase
      published.where("version_labels.normalized" => release_version.downcase, :target => target, :testtype => testtype).select("DISTINCT hardware").joins(:version_label).order("hardware")
    end

    def published_by_release_version_target(release_version, target, order_by = "tested_at DESC, id DESC", limit = nil)
      target = target.downcase
      published.where("version_labels.normalized" => release_version.downcase, :target => target).joins(:version_label).order(order_by).limit(limit)
    end

    def published_by_release_version(release_version, order_by = "tested_at DESC", limit = nil)
      published.where("version_labels.normalized" => release_version.downcase).joins(:version_label).order(order_by).limit(limit)
    end
  end

  ###############################################
  # List feature tags                           #
  ###############################################
  def self.list_targets(release_version)
    (published.all_lowercase(:select => 'DISTINCT target', :conditions=>{"version_labels.normalized" => release_version}, :include => :version_label).map { |s| s.target.gsub(/\b\w/) { $&.upcase } }).uniq
  end

  def self.list_types(release_version)
    (published.all_lowercase(:select => 'DISTINCT testtype', :conditions=>{"version_labels.normalized" => release_version}, :include => :version_label).map { |s| s.testtype.gsub(/\b\w/) { $&.upcase } }).uniq
  end

  def self.list_types_for(release_version, target)
    (published.all_lowercase(:select => 'DISTINCT testtype', :conditions=>{:target => target, "version_labels.normalized" => release_version}, :include => :version_label).map { |s| s.testtype.gsub(/\b\w/) { $&.upcase } }).uniq
  end

  def self.list_hardware(release_version)
    (published.all_lowercase(:select => 'DISTINCT hardware', :conditions=>{"version_labels.normalized" => release_version}, :include => :version_label).map { |s| s.hardware.gsub(/\b\w/) { $&.upcase } }).uniq
  end

  def self.list_hardware_for(release_version, target, testtype)
    (published.all_lowercase(:select => 'DISTINCT hardware',  :conditions=>{:target => target, :testtype=> testtype,"version_labels.normalized" => release_version}, :include => :version_label).map { |s| s.hardware.gsub(/\b\w/) { $&.upcase } }).uniq
  end


  ###############################################
  # Test session navigation                     #
  ###############################################
  def prev_session
    return @prev_session unless @prev_session.nil? and @has_prev.nil?
    tested = tested_at || Time.now
    created = created_at || Time.now

    @prev_session = MeegoTestSession.find(:first, :conditions => [
        "(tested_at < ? OR tested_at = ? AND created_at < ?) AND target = ? AND testtype = ? AND hardware = ? AND published = ? AND version_label_id = ?", tested, tested, created, target.downcase, testtype.downcase, hardware.downcase, true, version_label_id
    ],
                          :order => "tested_at DESC, created_at DESC", :include =>
         [{:meego_test_sets => :meego_test_cases}, {:meego_test_cases => :meego_test_set}])

    @has_prev = !@prev_session.nil?
    @prev_session
  end

  def next_session
    return @next_session unless @next_session.nil? and @has_next.nil?
    @next_session = MeegoTestSession.find(:first, :conditions => [
        "(tested_at > ? OR tested_at = ? AND created_at > ?) AND target = ? AND testtype = ? AND hardware = ? AND published = ? AND version_label_id = ?", tested_at, tested_at, created_at, target.downcase, testtype.downcase, hardware.downcase, true, version_label_id
    ],
                          :order => "tested_at ASC, created_at ASC", :include =>
         [{:meego_test_sets => :meego_test_cases}, {:meego_test_cases => :meego_test_set}])

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
    meego_test_sets.select {|set| set.has_nft?}
  end

  def non_nft_sets
    meego_test_sets.select {|set| set.has_non_nft?}
  end

  def test_case_by_name(feature, name)
    @test_case_hash ||= make_test_case_hash
    @test_case_hash[feature][name] unless @test_case_hash[feature].nil?
  end

  ###############################################
  # Chart visualization methods                 #
  ###############################################
  def summary_data
    data = Graph::Data.new
    data.passed = passed = []
    data.failed = failed = []
    data.na     = na     = []
    data.labels = labels = []

    prev = prev_session
    if prev
      pp = prev.prev_session
      if pp
        passed << pp.total_passed
        failed << pp.total_failed
        na     << pp.total_na
        labels << pp.formatted_date
      else
        passed << 0
        failed << 0
        na     << 0
        labels << ""
      end

      passed << prev.total_passed
      failed << prev.total_failed
      na     << prev.total_na
      labels << prev.formatted_date
    else
      passed << 0
      failed << 0
      na     << 0
      labels << ""
    end

    passed << total_passed
    failed << total_failed
    na     << total_na
    labels << "Current"

    data
  end

  def max_feature_cases
    meego_test_sets.map{|item| item.total_cases}.max
  end

  def non_empty_features
    meego_test_sets.select{|feature| feature.total_cases > 0}
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

  def build_id_html
    txt = build_id_txt
    if txt == ""
      "No build id details filled in yet"
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


  ###############################################
  # Small utility functions                     #
  ###############################################
  def updated_by(user)
    self.editor = user
    self.save
  end

  # Check that the target and release_version given as parameters
  # exist in label tables. Test session tables allow anything, but
  # if using other than what's in the label tables, the results
  # won't show up
  def validate_labels
    if target.blank?
      errors.add :target, "can't be blank"
    else
      label = TargetLabel.find(:first, :conditions => {:normalized => target.downcase})
      if not label
        valid_targets = TargetLabel.labels.join(",")
        errors.add :target, "Incorrect target '#{target}'. Valid ones are #{valid_targets}."
      end
    end

    if release_version.blank?
      errors.add :release_version, "can't be blank"
    else
      label = VersionLabel.find(:first, :conditions => {:normalized => release_version.downcase})
      if not label
        valid_versions = VersionLabel.versions.join(",")
        errors.add :release_version, "Incorrect release version '#{release_version}'. Valid ones are #{valid_versions}."
      end
    end

  end

  # Validate user entered test set and hw product. If all characters are
  # allowed users may enter characters that break the functionality. Thus,
  # restrict the allowed subset to certainly safe
  def validate_type_hw
    # \A and \z instead of ^ and $ cause multiline strings to fail validation.
    # And for the record: at least these characters break the navigation:
    # . % \ / (yes, dot is there as well for some oddball reason)
    allowed = /\A[\w\ \-:;,"\+\(\)]+\z/

    if not testtype.match(allowed)
      errors.add :testtype, "Incorrect test set. Please use only characters A-Z, a-z, 0-9, spaces and these special characters: , : ; - _ ( ) \" +"
    end

    if not hardware.match(allowed)
      errors.add :hardware, "Incorrect hardware. Please use only characters A-Z, a-z, 0-9, spaces and these special characters: , : ; - _ ( ) \" +"
    end
  end

  def force_testtype_hardware_names
    write_attribute :testtype, testtype_label
    write_attribute :hardware, hardware_label
  end

  def testtype_label
    @testtype_label = self.class.persistent_label_for(:testtype, testtype) if @testtype_label.nil? or testtype.casecmp(@testtype_label) != 0
    @testtype_label
  end

  def hardware_label
    @hardware_label = self.class.persistent_label_for(:hardware, hardware) if @hardware_label.nil? or hardware.casecmp(@hardware_label) != 0
    @hardware_label
  end

  def self.persistent_label_for(attribute, name)
    session = MeegoTestSession.select(attribute).find(:first, :conditions => {attribute => name})
    session.present? ? session.send(attribute) : name
  end


  def generate_defaults!
    time                 = tested_at || Time.now
    self.title           ||= "%s Test Report: %s %s %s" % [target, hardware_label, testtype_label, time.strftime('%Y-%m-%d')]
    self.environment_txt = "* Hardware: " + hardware if self.environment_txt.empty?
  end

  def format_date
    tested_at.strftime("%d.%m")
  end

  def format_year
    tested_at.strftime("%Y")
  end

  def self.map_result(result)
    result = result.downcase
    if result == "pass"
      1
    elsif result == "fail"
      -1
    else
      0
    end
  end

  def sanitize_filename(filename)
    filename.gsub(/[^\w\.\_\-]/, '_')
  end

  def valid_filename_extension?(filename)
    if filename =~ /\.csv$/i or filename =~ /\.xml$/i
      return true
    else
      errors.add :uploaded_files, "You can only upload files with the extension .xml or .csv"
      return false
    end
  end

  ###############################################
  # For encapsulating the release_version          #
  ###############################################
  def release_version=(release_version)
    version_label = VersionLabel.where( :normalized => release_version.downcase)
    self.version_label = version_label.first
  end

  def release_version
    if self.version_label
      return self.version_label.label
    else
      return nil
    end
  end

  def generate_file_destination_path(original_filename)
    datepart = Time.now.strftime("%Y%m%d")
    dir      = File.join(RESULT_FILES_DIR, datepart)
    dir      = File.join(INVALID_RESULTS_DIR, datepart) if !errors.empty? #store invalid results data for debugging purposes

    FileUtils.mkdir_p(dir)

    filename     = ("%06i-" % Time.now.usec) + sanitize_filename(original_filename)
    path_to_file = File.join(dir, filename)
  end


  ###############################################
  # File upload handlers                        #
  ###############################################

  def save_uploaded_files

    return unless @uploaded_files

    total_cases  = 0
    self.has_ft  = false
    self.has_nft = false

    @uploaded_files.each do |f|

      return if not valid_filename_extension?(f.original_filename)
      total_cases += parse_result_file(f.path, f.original_filename)

      path_to_file = generate_file_destination_path(f.original_filename)
      File.open(path_to_file, "wb") { |outf| outf.write(f.read) } #saves the uploaded file in server

      self.test_result_files.build(:path => path_to_file) #add the new test result file
    end

    if @uploaded_files.size > 0 and total_cases == 0
      if @uploaded_files.size == 1
        errors.add :uploaded_files, "The uploaded file didn't contain any valid test cases"
      else
        errors.add :uploaded_files, "None of the uploaded files contained any valid test cases"
      end
    end
  end

  def remove_uploaded_files
    # TODO: when report is deleted files should be deleted as well
  end

  def to_csv
    common_fields = [
        tested_at.to_date.to_s,
        release_version,
        target,
        testtype,
        hardware,
        title
    ]

    rows          = meego_test_cases.map do |test_case|
      test_case.meego_test_set.feature # feature
      test_case.name # test case name
      test_case.result # result
    end
  end

  def import_report(user, published = false)
    user.update_attribute(:default_target, self.target) if self.target.present?

    # See if there is a previous report with the same test target and type
    prev = self.prev_session
    if prev
      self.objective_txt     = prev.objective_txt if self.objective_txt.empty?
      self.build_txt         = prev.build_txt if self.build_txt.empty?
      self.environment_txt   = prev.environment_txt if self.environment_txt.empty?
      self.qa_summary_txt    = prev.qa_summary_txt if self.qa_summary_txt.empty?
      self.issue_summary_txt = prev.issue_summary_txt if self.issue_summary_txt.empty?
    end

    generate_defaults!

    self.author    = user
    self.editor    = user
    self.published = published
  end

  def clone_testcase_comments_from_session(target_session)
    meego_test_cases.where(:comment => '').includes(:meego_test_set).each do |tc| #select {|tc| tc.comment.blank? }.
      prev_comment = target_session.test_case_by_name(tc.meego_test_set.feature, tc.name).comment
      tc.update_attribute :comment, prev_comment unless prev_comment.blank?
    end
  end

  def update_report_result(user, resultfiles, published = true)
    @uploaded_files = resultfiles
    save_uploaded_files
    parsing_errors = errors[:uploaded_files]

    user.update_attribute(:default_target, self.target) if self.target.present?
    self.editor    = user
    self.published = published

    if !parsing_errors.empty?
      return parsing_errors.join(',')
    else
      return nil
    end
  end

  private

  ###############################################
  # Uploaded data parsing                       #
  ###############################################

  def parse_result_file(fpath,origfn)
    cases = 0
    begin
      if origfn =~ /.csv$/i
        cases = parse_csv_file(fpath)
      else
        cases = parse_xml_file(fpath)
      end
    rescue => e
      logger.error "ERROR in file parsing"
      logger.error origfn
      logger.error e
      logger.error e.backtrace
      errors.add :uploaded_files, "Incorrect file format for #{origfn}" + (": #{e}" if origfn =~ /.xml$/i).to_s
    end
    cases
  end


  def parse_csv_file(filename)
    prev_feature = nil
    test_set     = nil
    set_counts = {}
    sets       = {}
    total = 0

    rows         = CSV.read(filename);

    rows.shift # skip header row
    rows.each do |row|
      self.has_ft = true
      feature = row[0].toutf8.strip
      summary = row[1].toutf8.strip
      comments = row[2].toutf8.strip if row[2]
      passed = row[3]
      failed = row[4]
      na     = row[5]
      if feature != prev_feature
        sets[feature] ||= self.meego_test_sets.build(:feature => feature)
        test_set = sets[feature]
        prev_feature = feature
      end

      set_counter = if set_counts.has_key? feature
        set_counts[feature]
      else
        set_counts[feature] = Counter.new()
      end

      if passed == "1"
        result = 1
        set_counter.add_pass_count()
      elsif failed == "1"
        result = -1
      else
        result = 0
      end
      set_counter.add_total_count()

      if summary == ""
        raise "Missing test case name in CSV"
      end
      prev_tc = prev_session.test_case_by_name(feature, summary) unless prev_session.nil?
      prev_comment = prev_tc.comment unless prev_tc.nil?
      test_case = test_set.meego_test_cases.build(
          :name               => summary,
          :result             => result,
          :comment            => comments || prev_comment || "",
          :meego_test_session => self
      )

      total += 1
    end

    #if total == 0
    #  raise "File didn't contain any test cases"
    #end

    sets.each do |feature, set_model|
      feature_counter = set_counts[feature]
      set_model.grading = calculate_grading(
                  feature_counter.get_pass_count(),
                  feature_counter.get_total_count()
      )
    end
    total
  end

  def parse_xml_file(filename)
    sets = {}
    file_total = 0
    TestResults.new(File.open(filename)).suites.each do |suite|
      suite.sets.each do |set|
        ReportParser::parse_features(set.feature).each do |feature|
          sets[feature] ||= self.meego_test_sets.build(:feature => feature, :has_ft => false)
          set_model = sets[feature]

          pass_count = 0
          total_count = 0

          set.cases.each do |testcase|
            result = MeegoTestSession.map_result(testcase.result)
            prev_tc = prev_session.test_case_by_name(feature, testcase.name) unless prev_session.nil?
            prev_comment = prev_tc.comment unless prev_tc.nil?
            tc = set_model.meego_test_cases.build(
                :name               => testcase.name,
                :result             => result,
                :comment            => testcase.comment || prev_comment || "",
                :meego_test_session => self,
                :source_link        => testcase.source_url
            )
            pass_count += 1 if result == 1
            total_count += 1
            file_total += 1
            nft_index = 0
            testcase.measurements.each do |m|
              tc.has_nft = true
              set_model.has_nft = true
              self.has_nft = true
              if m.is_series?
                outline = self.calculate_outline(m.measurements,m.interval)
                tc.serial_measurements.build(
                  :name       => m.name,
                  :sort_index => nft_index,
                  :short_json => series_json(m.measurements, maxsize=40),
                  :long_json  => series_json_withx(m, outline.interval_unit, maxsize=200),
                  :unit       => m.unit,
                  :interval_unit => outline.interval_unit,

                  :min_value    => outline.minval,
                  :max_value    => outline.maxval,
                  :avg_value    => outline.avgval,
                  :median_value => outline.median
                )
              else
                tc.measurements.build(
                  :name       => m.name,
                  :sort_index => nft_index,
                  :value      => m.value,
                  :unit       => m.unit,
                  :target     => m.target,
                  :failure    => m.failure
                )
              end
              nft_index += 1
            end
            if nft_index == 0
              set_model.has_ft = true
              self.has_ft = true
            end
          end
          set_model.grading = calculate_grading(pass_count, total_count)
        end
      end
    end
    #if file_total == 0
    #  raise "The XML file didn't contain any test cases"
    #end
    file_total
  end

  def calculate_grading(pass_count, total_count)
    if total_count > 0
      pass_rate = pass_count * 100 / total_count
      if pass_rate < 40
        1
      elsif pass_rate < 90
        2
      else
        3
      end
    else
      0
    end
  end

  def create_version_label
    verlabel = VersionLabel.find(:first, :conditions => {:normalized => release_version.downcase})
    if verlabel
      self.version_label = verlabel
      save
    else
      verlabel = VersionLabel.new(:label => release_version, :normalized => release_version.downcase)
      verlabel.save
    end
  end

  def create_target_label
    tarlabel = TargetLabel.find(:first, :conditions => {:normalized => target.downcase})
    if tarlabel
      self.target = tarlabel.label
      save
    else
      tarlabel = TargetLabel.new(:label => target, :normalized => target.downcase)
      tarlabel.save
    end
  end

  def create_labels
    create_version_label && create_target_label
  end

  def make_test_case_hash
    test_cases = meego_test_cases.group_by {|tc| tc.meego_test_set.feature }
    test_cases.each_key do |feature|
      test_cases[feature] = Hash[test_cases[feature].map {|tc| [tc.name, tc]}]
    end
    test_cases
  end

end

class Counter
  def initialize()
    @pass_count = 0
    @total_count   = 0
  end

  def add_pass_count()
    @pass_count += 1
  end

  def add_total_count()
    @total_count +=1
  end

  def get_pass_count()
    @pass_count
  end

  def get_total_count()
    @total_count
  end
end

