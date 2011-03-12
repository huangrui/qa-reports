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

class MeegoTestSet < ActiveRecord::Base
  belongs_to :meego_test_session
   
  has_many :meego_test_cases, :dependent => :destroy
   
  include ReportSummary
  include Graph
   
  def has_nft?
    has_nft
  end

  def has_non_nft?
    has_ft
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
      @prev_summary = prevs.meego_test_sets.find(:first, :conditions => {:feature => feature})
    else
      nil
    end
  end

  def name
    feature
  end
  
  def max_cases
    meego_test_session.meego_test_sets.map{|item| item.total_cases}.max
  end

  def graph_img_tag
    html_graph(total_passed, total_failed, total_na, max_cases)
  end

  def test_set_link
    "#test-set-%i" % id
  end
  
end
