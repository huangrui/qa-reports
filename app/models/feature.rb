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
  has_many :special_features, :dependent => :destroy, :order => "id DESC"
  has_many :meego_test_cases, :autosave => false
  has_many :test_cases,       :class_name => "MeegoTestCase", :autosave => false,     :order => "id DESC"
  has_many :passed,           :class_name => "MeegoTestCase", :conditions => { :result => MeegoTestCase::PASS     }
  has_many :failed,           :class_name => "MeegoTestCase", :conditions => { :result => MeegoTestCase::FAIL     }
  has_many :na,               :class_name => "MeegoTestCase", :conditions => { :result => MeegoTestCase::NA       }
  has_many :measured,         :class_name => "MeegoTestCase", :conditions => { :result => MeegoTestCase::MEASURED }

  before_create :save_special_features

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

  def test_set_link
    "#test-set-%i" % id
  end

  def special_features_attributes=(attributes)
    attributes.each { |feature_attributes| special_features.build(feature_attributes) }
  end

  def save_special_features
    spec_feas = []
    special_features.each do |spec_fea|
      spec_fea.meego_test_session_id = meego_test_session_id
      spec_feas << spec_fea
    end
  end

  def merge!(feature_hash)
    current_spec_features = special_features.index_by &:name
    to_update, to_create = feature_hash[:special_features_attributes].
                           partition {|fh| current_spec_features.has_key? fh[:name]}

    to_update.each { |fh| current_spec_features[fh[:name]].merge! fh }

    to_create.each { |fh| special_features.create fh }

    self
  end
end
