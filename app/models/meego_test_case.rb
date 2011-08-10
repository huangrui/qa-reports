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
  default_scope where(:deleted => false)
  scope :deleted, where(:deleted => true)

  belongs_to :feature
  belongs_to :meego_test_session

  has_many :measurements, :dependent => :destroy, :class_name => "::MeegoMeasurement"
  has_many :serial_measurements, :dependent => :destroy
  has_many :meego_test_case_attachments, :dependent => :destroy

  accepts_nested_attributes_for :measurements, :serial_measurements

  PASS =  1
  FAIL = -1
  NA   =  0

  def self.by_name(name)
    where(:name => name).first
  end

  def unique_id
    (feature.name + "_" + name).downcase
  end

  def feature_key
    feature.name
  end

  def product_key
    meego_test_session.product.downcase
  end

  def find_matching_case(session)
    session.test_case_by_name(feature_key, name) unless session.nil?
  end

  def all_measurements
    a = (measurements + serial_measurements)
    a.sort!{|x,y| x.sort_index <=> y.sort_index}
  end

  def has_measurements?
    return !(measurements.empty? and serial_measurements.empty?)
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

  def attachments
    meego_test_case_attachments
  end

  def attachment=(attachment)
    attachments.clear
    attachments.build({:attachment=>attachment}) unless attachment.nil?
  end

  def update_attachment(attachment)
    attachments.clear
    attachments.create({:attachment=>attachment}) unless attachment.nil?
  end

  def self.import_from_array(test_cases)
    import test_cases, :validate => false
  end

  def remove_from_session
    update_attribute :deleted, true
  end

  def restore_to_session
    update_attribute :deleted, false
  end

end

