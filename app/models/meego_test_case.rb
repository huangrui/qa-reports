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

class MeegoTestCase < ActiveRecord::Base
  belongs_to :meego_test_set
  belongs_to :meego_test_session

  has_many :measurements, :dependent => :destroy, :class_name => "::MeegoMeasurement"

  def unique_id
    (meego_test_set.name + "_" + name).downcase
  end

  def find_matching_case(session)
    return nil unless session
    session.meego_test_cases.each do |tc|
      return tc if tc.name == name
    end
    nil
  end

  def has_measurements?
    return @has_measurements unless @has_measurements.nil?
    if measurements.loaded?
      @has_measurements = measurements.length > 0
    else
      @has_measurements = !measurements.empty?
    end
  end

  def find_change_class(prev_session)
    testcase = find_matching_case(prev_session)
    return '' unless testcase
    return case testcase.result
      when result then 'unchanged_result'
      when     -1 then 'changed_result changed_from_fail'
      when      0 then 'changed_result changed_from_na'
      when      1 then 'changed_result changed_from_pass'
    end
  end

end

