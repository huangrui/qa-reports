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

  before_filter :authenticate_user!

  def import_data
    data = request.query_parameters.merge(request.request_parameters)
    data.delete(:auth_token)

    errors                = []

    if !errors.empty?
      render :json => {:ok => '0', :errors => errors.join('; ')}
      return
    end

    data[:uploaded_files] = collect_files(data, "report", errors)
    attachments           = collect_files(data, "attachment", errors)

    if !errors.empty?
      render :json => {:ok => '0', :errors => "Request contained invalid files: " + errors.join(',')}
      return
    end

    data[:tested_at] = data[:tested_at] || Time.now

    begin
      @test_session = MeegoTestSession.new(data)
      @test_session.import_report(current_user, true)

    rescue ActiveRecord::UnknownAttributeError => error
      render :json => {:ok => '0', :errors => error.message}
      return
    end

    begin
      @test_session.save!

      expire_caches_for(@test_session, true)
      expire_index_for(@test_session)

      files = FileStorage.new()
      attachments.each { |file|
        files.add_file(@test_session, file, file.original_filename)
      }
      report_url = url_for :controller => 'reports', :action => 'view', :release_version => data[:release_version], :target => data[:target], :testtype => data[:testtype], :hwproduct => data[:hwproduct], :id => @test_session.id
      render :json => {:ok => '1', :url => report_url}
    rescue ActiveRecord::RecordInvalid => invalid
      error_messages = {}
      invalid.record.errors.each {|key, value| error_messages[key] = value}
      render :json => {:ok => '0', :errors => error_messages}
    end
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
      original_cases = []
      original_sets  = []
      begin
        @test_session = MeegoTestSession.find(@report_id)
        @test_session.meego_test_sets.each do |tset|
           original_sets << tset
        end
        @test_session.meego_test_cases.each do |tcase|
           original_cases << tcase
        end
        parse_err = @test_session.update_report_result(current_user, data[:uploaded_files], true)
      rescue ActiveRecord::UnknownAttributeError => errors
        render :json => {:ok => '0', :errors => errors.message}
        return
      end

      if parse_err.present?
        render :json => {:ok => '0', :errors => "Request contained invalid files: " + parse_err}
        return
      end

      if @test_session.valid?
        @test_session.save!

        expire_caches_for(@test_session, true)
        expire_index_for(@test_session)

      else
        render :json => {:ok => '0', :errors => invalid.record.errors}
        return
      end
      
      delete_dirty_data(original_sets)
      delete_dirty_data(original_cases)
      render :json => {:ok => '1'}
    end
  end

  private

  def delete_dirty_data(dirty_array)
    dirty_array.each do |dirty_item|
       dirty_item.delete
    end
  end

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
