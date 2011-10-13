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

  EXPORTER_CONFIG    = YAML.load_file("#{Rails.root.to_s}/config/qa-dashboard_config.yml")
  POST_TIMEOUT       = 8
  POST_RETRIES_LIMIT = 3

  def self.hashify_test_session(test_session)
    sets = []
    test_session.features.find(:all, :include => :meego_test_cases).each do |set|
      cases = []
      set.meego_test_cases.each do |c|
        bugs = c.comment.scan(/\[\[(\d+)\]\]/).map {|m| m[0].to_i}
        data = {
          "qa_id" => c.id,
          "name" => c.name,

          "result" => c.result,
          "comment" => c.comment,

          "bugs" => bugs
        }
        cases << data
      end

      data = {
        "qa_id" => set.id,
        "name" => set.name,

        "total_cases" => set.total_cases,
        "total_pass" => set.total_passed,
        "total_fail" => set.total_failed,
        "total_na" => set.total_na,
        "total_measured" => set.total_measured,

        "comments" => set.comments,

        "cases" => cases
      }
      sets << data
    end

    data = {
      "qa_id" => test_session.id,

      "title" => test_session.title,

      "hardware" => test_session.product,
      "profile" => test_session.profile.label,
      "testtype" => test_session.testset,
      "release" => test_session.release.name,

      "created_at" => test_session.created_at.utc,
      "updated_at" => test_session.updated_at.utc,
      "tested_at" => test_session.tested_at.utc,
      "weeknum" => Date.parse(test_session.tested_at.to_date.to_s).cweek(),

      "total_cases" => test_session.total_cases,
      "total_pass" => test_session.total_passed,
      "total_fail" => test_session.total_failed,
      "total_na" => test_session.total_na,
      "total_measured" => test_session.total_measured,

      "features" => sets,
    }
    data
  end

  def self.post(data, action)
    post_data = { "token" => EXPORTER_CONFIG['token'], "report" => data }.to_json
    uri       = EXPORTER_CONFIG['host'] + EXPORTER_CONFIG['uri'] + action
    headers   = { :content_type => :json, :accept => :json }

    tries = POST_RETRIES_LIMIT
    while(tries > 0)
      Rails.logger.debug "DEBUG: ReportExporter::post qa_id:#{data['qa_id'].to_s} uri:#{uri}"
      begin
        response = RestClient::Request.execute :method  => :post,
                                               :url     => uri,
                                               :timeout => POST_TIMEOUT + 3 * (POST_RETRIES_LIMIT - tries),
                                               :open_timeout => POST_TIMEOUT + 3 * (POST_RETRIES_LIMIT - tries),
                                               :payload => post_data,
                                               :headers => headers
      rescue => e
        tries -= 1
        Rails.logger.debug "DEBUG: ReportExporter::post exception: #{e.to_s} tries left:#{(tries)}"
        Rails.logger.debug "DEBUG: ReportExporter::post too many exceptions, giving up... (qa_id:#{data['qa_id'].to_s})" if tries == 0
      else
        Rails.logger.debug "DEBUG: ReportExporter::post res: #{response.to_str}" unless response.nil?
        break
      end
    end

    return tries > 0
  end

  def self.export_test_session(test_session)
    post ReportExporter::hashify_test_session(test_session), "update"
  end

  def self.delete_test_session_export(test_session)
    post({ "qa_id" => test_session.id }, "delete")
  end

end

