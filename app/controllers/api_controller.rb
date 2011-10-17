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

require 'file_storage'
require 'cache_helper'
class ApiController < ApplicationController
  include CacheHelper

  cache_sweeper :meego_test_session_sweeper, :only => [:import_data]
  before_filter :authenticate_user!, :except => :reports_by_limit_and_time

  def import_data
    data = request.query_parameters.merge(request.request_parameters)
    data.delete(:auth_token)

    errors = []

    data[:uploaded_files] = collect_files(data, "report", errors)
    attachments           = collect_files(data, "attachment", errors)

    if !errors.empty?
      render :json => {:ok => '0', :errors => "Request contained invalid files: " + errors.join(',')}
      return
    end

    data[:hardware] ||= data[:hwproduct]
    data[:product] ||= data[:hardware]
    data[:testset] ||= data[:testtype]
    data.delete(:hwproduct)
    data.delete(:testtype)
    data.delete(:hardware)

    begin
      @test_session = ReportFactory.new.build(data)
      @test_session.author = current_user
      @test_session.editor = current_user
      @test_session.published = true
    rescue ActiveRecord::UnknownAttributeError => error
      render :json => {:ok => '0', :errors => error.message}
      return
    end

    attachments.each do |file|
      @test_session.report_attachments.build(:attachment => file)
    end

    begin
      @test_session.save!

      #TODO: Use PaperClip
      files = FileStorage.new()
      attachments.each { |file|
        files.add_file(@test_session, file, file.original_filename)
      }

      report_url = url_for :controller => 'reports', :action => 'view', :release_version => data[:release_version], :target => data[:target], :testset => data[:testset], :product => data[:product], :id => @test_session.id
      render :json => {:ok => '1', :url => report_url}
    rescue ActiveRecord::RecordInvalid => invalid
      error_messages = {}
      invalid.record.errors.each {|key, value| error_messages[key] = value}
      render :json => {:ok => '0', :errors => error_messages}
    end

  end

  def hide_obsolete_results
    data = request.query_parameters.merge(request.request_parameters)
    data.delete(:auth_token)

    errors = []

    begin

      if data[:release_version].nil? || data[:target].nil? || data[:testtype].nil? || data[:hwproduct].nil?
        render :json => {:ok => '0', :errors => "Request input version, target, testtype, and hardware all the four keywords"}
        return
      end

      @test_sessions = MeegoTestSession.by_release_version_target_test_type_product(data[:release_version],data[:target],data[:testtype],data[:hwproduct])

      if @test_sessions.empty?
        errors << "version <= '#{data[:release_version]}'"
        errors << "target <= '#{data[:target]}'"
        errors << "testtype <= '#{data[:testtype]}'"
        errors << "hardware <= '#{data[:hwproduct]}'"
        render :json => {:ok => '0', :errors => "No reports searched out via the keywords:" + errors.join(',')}
        return
      end

      @test_sessions.each do |session|
        update_session =  MeegoTestSession.find(session.id)
        update_session.update_attributes(:editor => current_user, :updated_at => Time.now, :published => false)

        if update_session.valid?
          update_session.save!
        else
          render :json => {:ok => '0', :errors => invalid.record.errors}
          return
        end
      end

    rescue ActiveRecord::UnknownAttributeError => errors
      render :json => {:ok => '0', :errors => errors.message}
      return
    end

    report_count = @test_sessions.size

    render :json => {:ok => '1', :count => report_count}
  end

  def update_result
    data = request.query_parameters.merge(request.request_parameters)
    data.delete(:auth_token)

    errors                = []

    data[:uploaded_files] = collect_files(data, "report", errors)
    data[:updated_at] = data[:updated_at] || Time.now

    if !errors.empty?
      render :json => {:ok => '0', :errors => "Request contained invalid files: " + errors.join(',')}
      return
    end

    parse_err = nil

    if @report_id = params[:id].try(:to_i)
      begin
        @test_session = MeegoTestSession.find(@report_id)
        parse_err = @test_session.update_report_result(current_user, data, true)
      rescue ActiveRecord::UnknownAttributeError => errors
        render :json => {:ok => '0', :errors => errors.message}
        return
      end

      if parse_err.present?
        render :json => {:ok => '0', :errors => "Request contained invalid files: " + parse_err}
        return
      end

      if @test_session.save
        expire_caches_for(@test_session, true)
        expire_index_for(@test_session)
      else
        render :json => {:ok => '0', :errors => invalid.record.errors}
        return
      end

      render :json => {:ok => '1'}
    end
  end

  def reports_by_limit_and_time
    begin
      raise ArgumentError, "Limit not defined" if not params.has_key? :limit_amount
      sessions = MeegoTestSession.published.order("updated_at asc").limit(params[:limit_amount])
      if params.has_key? :begin_time
        begin_time = DateTime.parse params[:begin_time]
        sessions = sessions.where('updated_at > ?', begin_time)
      end
      hashed_sessions = sessions.map { |s| ReportExporter::hashify_test_session(s) }
      render :json => hashed_sessions
    rescue ArgumentError => error
      render :json => {:ok => '0', :errors => error.message}
    end
  end

  private

  def collect_file(parameters, key, errors)
    file = parameters.delete(key)
    if (file!=nil)
      if (!file.respond_to?(:path))
        errors << "Invalid file attachment for field " + key
      end
    end
    file
  end

  def collect_files(parameters, name, errors)
    results = []
    results << collect_file(parameters, name, errors)
    parameters.keys.select { |key|
      key.starts_with?(name+'.')
    }.sort.each { |key|
      results << collect_file(parameters, key, errors)
    }
    results.compact
  end

end
