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

  has_many :meego_test_cases, :autosave => false

  after_create :create_test_cases
  before_destroy :delete_test_cases

  include ReportSummary
  include Graph

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
    meego_test_cases.select {|tc| tc.has_nft}
  end

  def non_nft_cases
    meego_test_cases.select {|tc| !tc.has_nft}
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

  private

  def create_test_cases
    meego_test_cases.each {|tc| tc.feature_id = id; tc.meego_test_session_id = meego_test_session_id}
    if has_nft?
      meego_test_cases.each { |tc| tc.save! }
    else
      # when test cases have no associations to save, much faster bulk insertions can be used
      MeegoTestCase.import_from_array meego_test_cases
    end
  end

  def delete_test_cases
    MeegoTestCase.delete_all("feature_id = #{self.id}")
  end

end
