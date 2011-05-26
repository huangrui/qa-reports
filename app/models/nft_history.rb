#
# This file is part of meego-qa-reports
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

class NftHistory
  attr_reader :measurements, :start_date

  include MeasurementUtils
  

  def initialize(session)
    @session = session
    @first_nft_result_date = nil

    @trend_data = nil
  end
  
  def persisted?
    false
  end

  # Get the date of the first session with NFT results
  def start_date
    return @first_nft_result_date unless @first_nft_result_date.nil?

    first_session = MeegoTestSession.find(:first, 
                                          :conditions => 
                                          ["target = ? AND " + 
                                           "testtype = ? AND " +
                                           "hardware = ? AND " +
                                           "published = ? AND " +
                                           "version_label_id = ? AND " +
                                           "has_nft = ?",
                                           @session.target.downcase,
                                           @session.testtype.downcase,
                                           @session.hardware.downcase,
                                           true,
                                           @session.version_label_id,
                                           true],
                                          :order => "tested_at ASC")
    @first_nft_result_date = first_session.tested_at
  end

  # Get measurement trends for given session
  #
  # Read all matching measurement values from the beginning of the time until
  # given session (included) and return the data as CSV in a multidimensional 
  # hash that has keys as follows:
  # hash[feature_name][testcase_name][measurement_name] = CSV data
  def measurements
    return @trend_data unless @trend_data.nil?

    query = <<-END
    SELECT
    meego_test_sets.feature AS feature,
    meego_test_cases.name AS test_case,
    meego_measurements.name AS measurement,
    meego_measurements.unit AS unit,
    meego_measurements.value AS value,
    meego_test_sessions.tested_at AS tested_at
    FROM
    meego_measurements, meego_test_cases, meego_test_sets, meego_test_sessions
    WHERE
    meego_measurements.meego_test_case_id=meego_test_cases.id AND
    meego_test_cases.meego_test_set_id=meego_test_sets.id AND
    meego_test_sets.meego_test_session_id=meego_test_sessions.id AND
    meego_test_sessions.version_label_id=? AND
    meego_test_sessions.target=? AND
    meego_test_sessions.testtype=? AND
    meego_test_sessions.hardware=? AND
    meego_test_sessions.tested_at <= ? AND
    meego_test_sessions.published=?
    ORDER BY
    meego_test_sets.feature ASC, 
    meego_test_cases.name ASC,
    meego_measurements.name ASC,
    meego_test_sessions.tested_at ASC
    END

    data = MeegoTestSession.find_by_sql([query,
                                         @session.version_label_id,
                                         @session.read_attribute(:target),
                                         @session.testtype,
                                         @session.hardware,
                                         @session.tested_at,
                                         true])

    @trend_data = Hash.new
    feature = ""
    testcase = ""
    measurement = ""
    csv = ""
    json = []
    data.each do |m|
      # Start a new measurement
      if feature != m.feature or 
          testcase != m.test_case or 
          measurement != m.measurement 
        
        add_value(feature, testcase, measurement, "csv", csv) unless csv.empty?
        add_value(feature, testcase, measurement, "json", json) unless json.empty?

        unit = "Value"
        if not m.unit.nil?
          unit = m.unit
        end
        csv = "Date,#{unit}\n"
        json = []
        feature = m.feature
        testcase = m.test_case
        measurement = m.measurement
      end
      
      csv << m.tested_at.strftime("%Y-%m-%d") << "," << m.value.to_s << "\n"
      json << m.value
    end

    # Last one was not written in the loop above
    add_value(feature, testcase, measurement, "csv", csv) unless csv.empty?
    add_value(feature, testcase, measurement, "json", json) unless json.empty?

    count_key_figures

    @trend_data
  end

  protected

  def add_value(feature, testcase, measurement, format, data)

    if not @trend_data.has_key?(feature)
      @trend_data[feature] = Hash.new
    end

    if not @trend_data[feature].has_key?(testcase)
      @trend_data[feature][testcase] = Hash.new
    end

    if not @trend_data[feature][testcase].has_key?(measurement)
      @trend_data[feature][testcase][measurement] = Hash.new
    end
    
    @trend_data[feature][testcase][measurement][format] = data
  end

  def count_key_figures
    @trend_data.each do |f_key, f_value|
      f_value.each do |t_key, t_value|
        t_value.each do |m_key, m_value|
          if m_value.has_key?('json')
            data = m_value['json']
            
            m_value['min'] = 'N/A'
            m_value['max'] = 'N/A'
            m_value['avg'] = 'N/A'
            m_value['med'] = 'N/A'

            size = data.size
            if (size > 0)
              if (size % 2) == 0
                median = (data[size/2] + data[size/2-1])/2.0
              elsif size > 0
                median = data[size/2]
              end

              m_value['max'] = format_value(data.max, 3)
              m_value['min'] = format_value(data.min, 3)
              m_value['med'] = format_value(median, 3)
              m_value['avg'] = format_value(data.inject{|sum,el| sum + el}.to_f / size, 3)
            end
          end
        end
      end
    end
  end

end
