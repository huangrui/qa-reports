
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

require "nft"

  #TODO Get rid off decoration code and move to MeasurementShow (or TestCaseShow)
  class TargetResultWrapper
    attr_reader :result
    def initialize(res)
      @result = res
    end
  end

class MeegoMeasurement < ActiveRecord::Base
  belongs_to :meego_test_case

  include MeasurementUtils

  def is_serial?
    false
  end

  def target_html
    html(target)
  end

  def failure_html
    html(failure)
  end

  def value_html
    html(value)
  end

  def html(val, un=nil)
    un = unit if un.nil?
    "#{format_value(val, 3)}&nbsp;<span class=\"unit\">#{un}</span>".html_safe unless val.nil?
  end

  def index_html
    return "" if index.nil?
    html(index * 100, "%")
  end

  def index
    if target.nil? || target == 0
      nil
    elsif value.nil?
      0.0
    else
      [1.0, calculate_index_ratio].min # limit index to max 1.0
    end
  end

  def target_result
    TargetResultWrapper.new target_result_value
  end

  private

  def target_result_value
    if index.nil? or value.nil?
       0
    elsif index >= 1.0 or inside_fail_limit
       1
    else
      -1
    end
  end

  def inside_fail_limit
    return false if failure.nil?
    if reverse_calculation?
      value <= failure
    else
      value >= failure
    end
  end

  def calculate_index_ratio
    if reverse_calculation?
      value == 0 ? 1.0 : target.to_f / value
    else
      value / target.to_f
    end
  end

  REVERSE_UNITS = ["s", "ms"] # Less is better

  def reverse_calculation?
    failure.present? ? (failure > target) : REVERSE_UNITS.include?(unit.downcase)
  end

end
