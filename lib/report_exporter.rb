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

module ReportExporter

  EXPORTER_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/qa-dashboard_config.yml")

  def self.hashify_test_session(test_session)
    sets = []
    test_session.meego_test_sets.each do |set|
      cases = []
      set.meego_test_cases.each do |c|
        bugs = c.comment.scan(/\[\[(\d+)\]\]/).map {|m| m[0].to_i}
        data = {
          "report_id" => c.id,
          "name" => c.name,

          "result" => c.result,
          "comment" => c.comment,

          "bugs" => bugs
        }
        cases << data
      end

      data = {
        "report_id" => set.id,
        "name" => set.feature,
      
        "total_cases" => set.total_cases,
        "total_pass" => set.total_passed,
        "total_fail" => set.total_failed,
        "total_na" => set.total_na,

        "comments" => set.comments,

        "cases" => cases
      }
      sets << data
    end

    data = {
      "report_id" => test_session.id,

      "title" => test_session.title,

      "hardware" => test_session.hardware,
      "profile" => test_session.target,
      "testtype" => test_session.testtype,
      "release" => test_session.release_version,

      "created_at" => test_session.created_at.utc,
      "updated_at" => test_session.updated_at.utc,
      "tested_at" => test_session.tested_at.utc,
      "weeknum" => Date.parse(test_session.tested_at.to_date.to_s).cweek(),

      "total_cases" => test_session.total_cases,
      "total_pass" => test_session.total_passed,
      "total_fail" => test_session.total_failed,
      "total_na" => test_session.total_na,

      "features" => sets,
    }
    data
  end

  def self.post(data)
    postdata = { "token" => EXPORTER_CONFIG['token'], "report" => data }
    begin
      response = RestClient.post EXPORTER_CONFIG['uri'], postdata.to_json, :content_type => :json, :accept => :json
    rescue => e
      Rails.logger.debug "DEBUG: ReportExporter::post failed, report_id:" + data['report_id'].to_s + " error:" + e.to_s
    end
    Rails.logger.debug "DEBUG: ReportExporter::post report_id:" + data['report_id'].to_s + " res:" + response.to_str if !response.nil? #debug

  end

  def self.export_test_session(test_session)
    post(ReportExporter::hashify_test_session(test_session))
  end

end

