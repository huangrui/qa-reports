# Copyright (C) 2010 Intel Corporation
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# Authors:
#       Huang Rui  <rui.r.huang@intel.com>
# Date Created: 2012/02/20
#
# Modifications:
#          Modificator  Date
#          Content of Modification
#

require 'testreport'
require 'graph'

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
  include Graph

  def find_matching_special_feature(session)
    return nil unless session
    session.features.each do |f|
      if f.name == self.feature.name
        f.special_features.each do |sf|
          return sf if sf.name == name
        end
      end
    end
    nil
  end

  def meego_test_cases_attributes=(attributes)
    attributes.each { |test_case_attributes| meego_test_cases.build(test_case_attributes) }
  end

  def non_nft_cases
    meego_test_cases.select {|tc| !tc.has_measurements?}
  end

  def non_nft_fail_na_cases
    testcases = self.non_nft_cases.select{|tc| tc.result != MeegoTestCase::PASS}
  end

  def grading
    calculate_grading
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
