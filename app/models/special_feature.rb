require 'testreport'

class SpecialFeature < ActiveRecord::Base
  belongs_to :meego_test_session
  belongs_to :feature

  has_many :meego_test_cases, :autosave => false, :dependent => :destroy
  has_many :test_cases,       :class_name => "MeegoTestCase", :autosave => false,     :order => "id DESC"
  has_many :passed,           :class_name => "MeegoTestCase", :conditions => { :result => MeegoTestCase::PASS     }
  has_many :failed,           :class_name => "MeegoTestCase", :conditions => { :result => MeegoTestCase::FAIL     }
  has_many :na,               :class_name => "MeegoTestCase", :conditions => { :result => MeegoTestCase::NA       }
  has_many :measured,         :class_name => "MeegoTestCase", :conditions => { :result => MeegoTestCase::MEASURED }

  after_create :save_test_cases

  include ReportSummary

  def meego_test_cases_attributes=(attributes)
    attributes.each { |test_case_attributes| meego_test_cases.build(test_case_attributes) }
  end

  def save_test_cases
    test_cases = []
    meego_test_cases.each do |test_case|
      test_case.special_feature_id = id
      test_case.feature_id = feature_id
      test_case.meego_test_session_id = meego_test_session_id
      if !test_case.measurements.empty? or !test_case.serial_measurements.empty?
        test_case.save!
      else
        test_cases << test_case
      end
    end

    MeegoTestCase.import test_cases, :validate => false
  end

  def merge!(feature_hash)
    current_cases = test_cases.index_by &:name
    existing_cases, new_cases = feature_hash[:meego_test_cases_attributes].
                           partition {|ch| current_cases.has_key? ch[:name] }

    test_cases.delete existing_cases.map { |ch| current_cases[ch[:name]].destroy }

    (existing_cases + new_cases).each do |ch|
      test_cases.create ch.merge({:meego_test_session_id => meego_test_session.id, :feature_id => feature.id})
    end
  end
end
