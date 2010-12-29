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
        files.add_file(@test_session, file, MeegoTestSession::get_filename(file))
      }
      render :json => {:ok => '1'}
    rescue ActiveRecord::RecordInvalid => invalid
      render :json => {:ok => '0', :errors => invalid.record.errors}
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
