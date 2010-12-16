#
# This file is part of meego-test-reports
#
# Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
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

class ComparisonResult
  include MeegoTestCaseHelper

  def initialize(left, right, changed)
    @left    = left
    @right   = right
    @changed = changed
  end

  def left
    @left
  end

  def right
    @right
  end

  def changed
    @changed
  end

  def name
    if @left != nil
      @left.name
    else
      @right.name
    end    
  end
end

class ComparisonRow
  def initialize(name)
    @name = name
    @values = {}
  end

  def value(column)
    @values[column.downcase] || ComparisonResult.new(nil, nil, false)
  end

  def add_value(column, value)
    @values[column.downcase] =value
  end

  def changed
    @values.select { |key, value| value.changed }.length > 0
  end
end

class ComparisonGroup
  def initialize(name)
    @name    = name
    @rows = {}
  end

  def name
    @name
  end

  def names
    @rows.keys
  end

  def row(name)
    rows = @rows[name.downcase] || ComparisonRow.new(name)
    @rows[name.downcase] = rows
  end

  def changed
    @rows.select { |key, value| value.changed }.length > 0
  end
end

class ReportComparison

  def initialize()
    @new_failing     = 0
    @new_passing     = 0
    @new_na          = 0
    @changed_to_pass = 0
    @changed_to_fail = 0
    @changed_to_na   = 0
    @groups          = []
    @columns = []
  end

  def columns
    @columns
  end

  def add_pair(column, old_report, new_report)
    add_column(column)
    reference      = Hash[*new_report.meego_test_cases.collect { |test_case| [test_case.name, test_case] }.flatten]
    @changed_cases = old_report.meego_test_cases.select { |test_case|
      old     = test_case
      new     = reference.delete(test_case.name)
      changed = update_summary(old, new)
      update_group(column, old, new, changed)
      changed
    }.push(*reference.values.select { |test_case|
      new = test_case
      update_summary(nil, new)
      update_group(column, nil, new, true)
      true
    })
  end

  def changed_to_fail
    format_result(-@changed_to_fail)
  end

  def changed_to_pass
    format_result(@changed_to_pass)
  end

  def changed_to_na
    format_result(@changed_to_na)
  end

  def new_na
    @new_na.to_s
  end

  def new_passing
    @new_passing.to_s
  end

  def new_failing
    @new_failing.to_s
  end

  def changed_test_cases
    @changed_cases
  end

  def old_report
    @old_report
  end

  def new_report
    @new_report
  end

  def groups
    @groups
  end

  private

  def add_column(column)
    if !@columns.include?(column)
      @columns<<column
    end
  end

  def format_result(result)
    if result>0
      "+" + result.to_s
    else
      result.to_s
    end
  end

  def update_group(column, old, new, changed)
    name  = if new!=nil
              new.meego_test_set.name
            elsif old!=nil
              old.meego_test_set.name
            else
              "N/A"
            end
    group = @groups.select { |group| group.name.casecmp(name) == 0 }.first || @groups.push(ComparisonGroup.new(name)).last
    result = ComparisonResult.new(old, new, changed)
    group.row(result.name).add_value(column, result)
  end

  def update_summary(old, new)
    if old == nil
      case new.result
        when -1 then
          @new_failing += 1
        when 0 then
          @new_na += 1
        when 1 then
          @new_passing += 1
        else
          throw :invalid_value
      end
    elsif new == nil
      # test disappeared
      if old.result == 0
        return false
      end
      @changed_to_na += 1
    elsif new.result!=old.result
      case new.result
        when 1 then
          @changed_to_pass += 1
        when 0 then
          @changed_to_na += 1
        when -1 then
          @changed_to_fail += 1
        else
          throw :invalid_value
      end
    else
      return false
    end
    true
  end
end