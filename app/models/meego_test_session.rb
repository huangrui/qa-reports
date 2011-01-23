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
require 'bitly'
require 'trimmer'
require 'report_parser'
require 'validation/date_time_validator'
require 'will_paginate'

#noinspection Rails3Deprecated
class MeegoTestSession < ActiveRecord::Base
  include Trimmer

  has_many :meego_test_sets, :dependent => :destroy
  has_many :meego_test_cases

  belongs_to :author, :class_name => "User"
  belongs_to :editor, :class_name => "User"

  validates_presence_of :title, :target, :testtype, :hwproduct
  validates_presence_of :uploaded_files, :on => :create

  validates :tested_at, :date_time => true

  validate :allowed_filename_extensions, :on => :create
  validate :save_uploaded_files, :on => :create

  #after_create :save_uploaded_files
  after_destroy :remove_uploaded_files

  attr_reader :parsing_failed, :parse_errors

  scope :published, :conditions => {:published => true}

  XML_DIR = "public/reports"

  include ReportSummary

  def target=(target)
    target = target.try(:downcase)
    write_attribute(:target, target)
  end

  def target
    read_attribute(:target).try(:capitalize)
  end

  def testtype=(testtype)
    testtype = testtype.try(:downcase)
    write_attribute(:testtype, testtype)
  end

  def testtype
    read_attribute(:testtype).try(:capitalize)
  end

  def hwproduct=(hwproduct)
    hwproduct = hwproduct.try(:downcase)
    write_attribute(:hwproduct, hwproduct)
  end

  def hwproduct
    read_attribute(:hwproduct).try(:capitalize)
  end

  def prev_summary
    prev_session
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
    ['Core', 'Handset', 'Netbook', 'IVI', 'SDK']
  end  

  def self.release_versions
    # Add new release versions to the beginning of the array.
    ["1.2", "1.1", "1.0"]
  end

  def self.latest_release_version
    release_versions[0]
  end

  def self.filters_exist?(target, testtype, hwproduct)
    return true if target.blank? and testtype.blank? and hwproduct.blank?
    
    filters_exist = false

    if target.present?
      filters_exist = find_by_target(target.downcase).present?

      if testtype.present?
        filters_exist &= find_by_testtype(testtype.downcase).present?
      end

      if testtype.present? && hwproduct.present?
        filters_exist &= find_by_hwproduct(hwproduct.downcase).present?
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
    def by_release_version_target_test_type_product(release_version, target, testtype, hwproduct, order_by = "tested_at DESC", limit = nil)
      target    = target.downcase
      testtype  = testtype.downcase
      hwproduct = hwproduct.downcase
      published.where(:release_version => release_version, :target => target, :testtype => testtype, :hwproduct => hwproduct).order(order_by).limit(limit)
    end

    def published_by_release_version_target_test_type(release_version, target, testtype, order_by = "tested_at DESC", limit = nil)
      target   = target.downcase
      testtype = testtype.downcase
      published.where(:release_version => release_version, :target => target, :testtype => testtype).order(order_by).limit(limit)
    end

    def published_hwversion_by_release_version_target_test_type(release_version, target, testtype)
      target   = target.downcase
      testtype = testtype.downcase
      published.where(:release_version => release_version, :target => target, :testtype => testtype).select("DISTINCT hwproduct").order("hwproduct")
    end

    def published_by_release_version_target(release_version, target, order_by = "tested_at DESC", limit = nil)
      target = target.downcase
      published.where(:release_version => release_version, :target => target).order(order_by).limit(limit)
    end

    def published_by_release_version(release_version, order_by = "tested_at DESC", limit = nil)
      published.where(:release_version => release_version).order(order_by).limit(limit)
    end
  end

  ###############################################
  # List feature tags                           #
  ###############################################
  def self.list_targets(release_version)
    (published.all_lowercase(:select => 'DISTINCT target', :conditions=>{:release_version => release_version}).map { |s| s.target.gsub(/\b\w/) { $&.upcase } }).uniq
  end

  def self.list_types(release_version)
    (published.all_lowercase(:select => 'DISTINCT testtype', :conditions=>{:release_version => release_version}).map { |s| s.testtype.gsub(/\b\w/) { $&.upcase } }).uniq
  end

  def self.list_types_for(release_version, target)
    (published.all_lowercase(:select => 'DISTINCT testtype', :conditions => {:target => target, :release_version => release_version}).map { |s| s.testtype.gsub(/\b\w/) { $&.upcase } }).uniq
  end

  def self.list_hardware(release_version)
    (published.all_lowercase(:select => 'DISTINCT hwproduct', :conditions=>{:release_version => release_version}).map { |s| s.hwproduct.gsub(/\b\w/) { $&.upcase } }).uniq
  end

  def self.list_hardware_for(release_version, target, testtype)
    (published.all_lowercase(:select => 'DISTINCT hwproduct', :conditions => {:target => target, :testtype=> testtype, :release_version => release_version}).map { |s| s.hwproduct.gsub(/\b\w/) { $&.upcase } }).uniq
  end


  ###############################################
  # Test session navigation                     #
  ###############################################
  def prev_session
    time = tested_at || Time.now
    MeegoTestSession.find(:first, :conditions => [
        "tested_at < ? AND target = ? AND testtype = ? AND hwproduct = ? AND published = ? AND release_version = ?", time, target.downcase, testtype.downcase, hwproduct.downcase, true, release_version
    ],
                          :order              => "tested_at DESC")
  end

  def next_session
    MeegoTestSession.find(:first, :conditions => [
        "tested_at > ? AND target = ? AND testtype = ? AND hwproduct = ? AND published = ? AND release_version = ?", tested_at, target.downcase, testtype.downcase, hwproduct.downcase, true, release_version
    ],
                          :order              => "tested_at ASC")
  end

  ###############################################
  # Utility methods for viewing a report        #
  ###############################################
  def formatted_date
    tested_at ? tested_at.strftime("%Y-%m-%d") : 'n/a'
  end

  ###############################################
  # Chart visualization methods                 #
  ###############################################
  def graph_img_tag(format_email)
    values = [0, 0, total_passed, 0, 0, total_failed, 0, 0, total_na]
    labels = ["", "", "Current"]
    totals = [0, 0, total_cases]
    prev   = prev_session
    if prev
      values[1] = prev.total_passed
      values[4] = prev.total_failed
      values[7] = prev.total_na
      labels[1] = prev.formatted_date
      totals[1] = prev.total_cases
      pp        = prev.prev_session
      if pp
        values[0] = pp.total_passed
        values[3] = pp.total_failed
        values[6] = pp.total_na
        labels[0] = pp.formatted_date
        totals[0] = prev.total_cases
      end
    end
    scale = [totals.max, 10].max
    step  = scale/9.0
    step  = (step.to_i/5)*5
    if (scale % 45) != 0
      step += 5
    end
    scale        = (scale/step+1)*step
    chart_size   = "385x200"
    chart_type   = "bvs" # bar, vertical, stacked
    chart_colors = "BCCD98|BCCD98|73a20c,E7ABAB|E7ABAB|ec4343,DBDBDB|DBDBDB|CACACA"
    chart_data   = "t:%i,%i,%i|%i,%i,%i|%i,%i,%i" % values
    chart_scale  = "0,%i" % scale
    #chart_margins = "0,0,0,0"
    chart_fill   = "bg,s,ffffffff"
    chart_width  = "90,30,30"
    chart_axis   = "x,y"
    chart_labels = "%s|%s|%s" % labels
    chart_range  = "1,0,%i,%i" % [scale, step]

    #url = "http://chart.apis.google.com/chart?cht=#{chart_type}&chs=#{chart_size}&chco=#{chart_colors}&chd=#{chart_data}&chds=#{chart_scale}&chma=#{chart_margins}&chf=#{chart_fill}&chbh=#{chart_width}&chxt=#{chart_axis}&chl=#{chart_labels}&chxr=#{chart_range}"
    url          = "http://chart.apis.google.com/chart?cht=#{chart_type}&chs=#{chart_size}&chco=#{chart_colors}&chd=#{chart_data}&chds=#{chart_scale}&chf=#{chart_fill}&chbh=#{chart_width}&chxt=#{chart_axis}&chl=#{chart_labels}&chxr=#{chart_range}"

    if (format_email)
      Bitly.use_api_version_3
      bitly = Bitly.new("leonidasoy", "R_b1aca98d073e7a78793eec01f3340fb4")
      url   = bitly.shorten(url).short_url
    end

    "<div class=\"bvs_wrap\"><img class=\"bvs\" src=\"#{url}\"/></div>".html_safe
  end

  def small_graph_img_tag(max_cases)
    chart_size    = "386x14"
    chart_type    = "bhs:nda" # bar, horizontal, stacked
    chart_colors  = "73a20c,ec4343,CACACA"
    chart_data    = "t:%i|%i|%i" % [total_passed, total_failed, total_na]
    chart_scale   = "0,%i" % ([max_cases, 15].max)
    chart_margins = "0,0,0,0"
    chart_fill    = "bg,s,ffffff00"
    chart_width   = "14,0,0"

    url           = "http://chart.apis.google.com/chart?cht=#{chart_type}&chs=#{chart_size}&chco=#{chart_colors}&chd=#{chart_data}&chds=#{chart_scale}&chma=#{chart_margins}&chf=#{chart_fill}&chbh=#{chart_width}"

    "<div class=\"bhs_wrap\"><img class=\"bhs\" src=\"#{url}\"/></div>".html_safe
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


  ###############################################
  # Small utility functions                     #
  ###############################################
  def updated_by(user)
    self.editor = user
    self.save
  end

  def generate_defaults!
    time                 = tested_at || Time.now
    self.title           = "%s Test Report: %s %s %s" % [target, hwproduct, testtype, time.strftime('%Y-%m-%d')]
    self.environment_txt = "* Hardware: " + hwproduct
  end

  def format_date
    tested_at.strftime("%d.%m")
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

  def sanitize_filename(f)
    filename      = if f.respond_to?(:original_filename)
                      f.original_filename
                    else
                      f.path
                    end
    just_filename = File.basename(filename)
    just_filename.gsub(/[^\w\.\_\-]/, '_')
  end


  ###############################################
  # File upload handlers                        #
  ###############################################
  def uploaded_files=(files)
    @files = files
  end

  def uploaded_files
    @files
  end

  def allowed_filename_extensions
    @files.each do |f|
      filename = MeegoTestSession::get_filename(f)
      filename = filename.downcase.strip
      if filename == ""
        errors.add :uploaded_files, "can't be blank"
        "File name can't be blank"
        return
      end
      unless filename =~ /\.csv$/ or filename =~ /\.xml$/
        errors.add :uploaded_files, "You can only upload files with the extension .xml or .csv"
        filename
        return
      end
    end if @files
    nil
  end

  def save_uploaded_files
    @parsing_failed = false
    return unless @files
    total_cases = 0
    
    error_msgs = []

    MeegoTestSession.transaction do
      filenames     = []
      @parse_errors = []
      @files.each do |f|
        datepart = Time.now.strftime("%Y%m%d")
        dir      = File.join(XML_DIR, datepart)

        begin
          f = if f.respond_to?(:original_filename)
                f
              elsif f.respond_to?(:path)
                f
              else
                File.new(f.gsub(/\#.*/, ''))
              end
        rescue
          errors.add :uploaded_files, "can't be blank"
          return
        end

        filename     = sanitize_filename(f)

        origfn       = File.basename(filename)
        filename     = ("%06i-" % Time.now.usec) + filename
        path_to_file = File.join(dir, filename)
        filenames << path_to_file
        if !File.exists?(dir)
          Dir.mkdir(dir)
        end
        if f.respond_to? :read
          File.open(path_to_file, "wb") { |outf| outf.write(f.read) }
        else
          FileUtils.copy(f.local_path, path_to_file)
        end

        # XXX: ugly hack to circumvent capybara/envjs bug in file uploading
        if ::Rails.env == 'test'
          data = File.read(path_to_file)
          if data =~ /^Content-Type:/
            data = data.sub /Content-Type: .*?\r\nContent-Length: .*?\r\n\r\n/, ""
            count = File.open(path_to_file, 'w') {|f| f.write(data)}
          end
        end

        begin
          if filename =~ /.csv$/
            total_cases += parse_csv_file(path_to_file)
          else
            total_cases += parse_xml_file(path_to_file)
          end
        rescue
          logger.error "ERROR in file parsing"
          logger.error $!, $!.backtrace
          content = File.open(path_to_file).read
          errors.add :uploaded_files, "Incorrect file format for #{origfn}: #{content}"
          error_msgs << "Incorrect file format for #{origfn}: #{content}"
        end
      end
      @xmlpath = filenames.join(',')
      if @files.size > 0 and total_cases == 0
        if @files.size == 1
          errors.add :uploaded_files, "The uploaded file didn't contain any valid test cases"
        else
          errors.add :uploaded_files, "None of the uploaded files contained any valid test cases"
        end
      end
      if !error_msgs.empty?
          error_msgs.join(',')
      else
          nil
      end
    end
  end

  def remove_uploaded_files
    # TODO
  end

  def to_csv
    common_fields = [
        tested_at.to_date.to_s,
        release_version,
        target,
        testtype,
        hwproduct,
        title
    ]

    rows          = meego_test_cases.map do |test_case|
      test_case.meego_test_set.feature # feature
      test_case.name # test case name
      test_case.result # result
    end
  end

  def import_report(user, published = false)
    generate_defaults!
    user.update_attribute(:default_target, self.target) if self.target.present?

    # See if there is a previous report with the same test target and type
    prev = self.prev_session
    if prev
      self.objective_txt     = prev.objective_txt
      self.build_txt         = prev.build_txt
      self.qa_summary_txt    = prev.qa_summary_txt
      self.issue_summary_txt = prev.issue_summary_txt
    end

    self.author    = user
    self.editor    = user
    self.published = published
  end

  def update_report_result(user, resultfiles, published = true)
    @files = resultfiles
    parsing_errors = []
    temp_err = allowed_filename_extensions
    if (nil != temp_err)
       parsing_errors << temp_err
    end
    temp_err = save_uploaded_files
    if (nil != temp_err)
       parsing_errors << temp_err
    end
    user.update_attribute(:default_target, self.target) if self.target.present?
    self.editor    = user
    self.published = published
    
    if !parsing_errors.empty?
       parsing_errors.join(',')
    else
       nil
    end
  end

  def self.get_filename(file)
    if file.respond_to?(:original_filename)
      file.original_filename
    elsif file.respond_to?(:path)
      file.path
    else
      file.gsub(/\#.*/, '')
    end
  end

  private

  ###############################################
  # Uploaded data parsing                       #
  ###############################################
  def parse_csv_file(filename)
    prev_feature = nil
    test_set     = nil
    set_counts = {}
    sets       = {}
    total = 0

    rows         = CSV.read(filename);
    rows.shift # skip header row
    rows.each do |row|
      feature = row[0].toutf8.strip
      summary = row[1].toutf8.strip
      comments = row[2].toutf8.strip if row[2]
      passed = row[3]
      failed = row[4]
      na     = row[5]
      if feature != prev_feature
        test_set = if sets.has_key? feature
          sets[feature]
        else
          sets[feature] = self.meego_test_sets.build(:feature => feature)
        end
        prev_feature = feature
      end

      set_counter = if set_counts.has_key? feature
        set_counts[feature]
      else
        set_counts[feature] = Counter.new()
      end

      if passed
        result = 1
        set_counter.add_pass_count()
      elsif failed
        result = -1
      else
        result = 0
      end
      set_counter.add_total_count()

      if summary == ""
        raise "Missing test case name in CSV"
      end
      test_case = test_set.meego_test_cases.build(
          :name               => summary,
          :result             => result,
          :comment            => comments || "",
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

          set_model = if sets.has_key? feature
            sets[feature]
          else
            sets[feature] = self.meego_test_sets.build(:feature => feature)
          end

          pass_count = 0
          total_count = 0

          set.cases.each do |testcase|
            result = MeegoTestSession.map_result(testcase.result)
            set_model.meego_test_cases.build(
                :name               => testcase.name,
                :result             => result,
                :comment            => testcase.comment,
                :meego_test_session => self,
                :source_link        => testcase.source_url
            )
            pass_count += 1 if result == 1
            total_count += 1
            file_total += 1
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

