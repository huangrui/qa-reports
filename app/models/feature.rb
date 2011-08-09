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
require 'graph'

class Feature < ActiveRecord::Base
  belongs_to :meego_test_session
  has_many :meego_test_cases, :autosave => false, :dependent => :destroy

  after_save :save_test_cases

  include ReportSummary
  include Graph


  def self.by_feature(feature)
    where(:name => feature).first
  end

  def find_matching_feature(session)
    return nil unless session
    session.features.each do |f|
      return f if f.name == name
    end
    nil
  end

  def grading
    read_attribute(:grading) || calculate_grading
  end

  def nft_cases
    meego_test_cases.select {|tc| tc.has_measurements?}
  end

  def non_nft_cases
    meego_test_cases.select {|tc| !tc.has_measurements?}
  end

  def prev_summary
    return @prev_summary unless @prev_summary.nil?
    prevs = meego_test_session.prev_session
    if prevs
      @prev_summary = prevs.features.find(:first, :conditions => {:name => name})
    else
      nil
    end
  end

  def graph_img_tag(max_cases)
    html_graph(total_passed, total_failed, total_na, max_cases)
  end

  def test_set_link
    "#test-set-%i" % id
  end

  def meego_test_cases_attributes=(attributes)
    attributes.each { |test_case_attributes| meego_test_cases.build(test_case_attributes) }
  end

  def save_test_cases
    test_cases = []
    meego_test_cases.each do |test_case|
      test_case.feature_id = id
      test_case.meego_test_session_id = meego_test_session_id
      if !test_case.measurements.empty? or !test_case.serial_measurements.empty?
        test_case.save!
      else
        test_cases << test_case
      end
    end

    MeegoTestCase.import test_cases, :validate => false
  end

end
