#
# This file is part of meego-test-reports
#
# Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
#
# Authors: Sami Hangaslammi <sami.hangaslammi@leonidasoy.fi>
#          Jarno Keskikangas <jarno.keskikangas@leonidasoy.fi>
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

require 'drag_n_drop_uploaded_file'
require 'cache_helper'

class UploadController < ApplicationController
  include CacheHelper
  
  cache_sweeper :meego_test_session_sweeper, :only => [:upload]
  before_filter :authenticate_user!
  
  def upload_form
    new_report = {}
    [:release_version, :target, :testtype, :hardware].each do |key| 
      new_report[key] = params[key] if params[key]
    end

    new_report[:release] = new_report[:release].downcase if new_report[:release]
    new_report[:target] ||= new_report[:target].downcase if new_report[:target]
    new_report[:target] ||= MeegoTestSession.targets.first.downcase
    @test_session = MeegoTestSession.new(new_report)
    @test_session.version_label = VersionLabel.find_by_label(new_report[:release_version]) || VersionLabel.latest

    @release_versions = VersionLabel.in_sort_order.map { |release| release.label }
    @targets = MeegoTestSession.targets.map {|target| target.downcase}
    @testtypes = MeegoTestSession.release(@selected_release_version).testtypes
    @hardware = MeegoTestSession.release(@selected_release_version).popular_hardwares

    @no_upload_link = true
  end

  def upload_report
    raw_filename = env['HTTP_X_FILE_NAME']
    extension = File.extname(raw_filename)
    fileid = env['HTTP_X_FILE_ID']
    raw_filename_wo_extension = File.basename(env['HTTP_X_FILE_NAME'], extension)

    # TODO: Temp files needs to be deleted periodically
    url      = "/reports/tmp/#{raw_filename_wo_extension.parameterize}#{extension}"
    filename = "#{Rails.root}/public#{url}"

    value = env['rack.input'].read()
    File.open(filename, 'wb') {|f| f.write( value ) }
    render :json => { :ok => '1', :fileid => fileid, :url => url }
  end

  def upload_attachment
    files = FileStorage.new()
    session = MeegoTestSession.find(params[:id]);
    files.add_file(session, request['Filedata'], request['Filename'])
    @editing = true

    expire_caches_for(session)
    # full file name of template has to be given because flash uploader can pass header HTTP_ACCEPT: text/*
    # file is not found because render :formats=>[:"text/*"]
    render :partial => 'reports/file_attachment_list.html.erb', :locals => {:report => session, :files => files.list_files(session)}
  end
  
  def upload
    params[:meego_test_session][:uploaded_files] ||= []
    params[:drag_n_drop_attachments] ||= []
    
    # Harmonize file handling between drag'n drop and form upload
    params[:drag_n_drop_attachments].each do |name|
      params[:meego_test_session][:uploaded_files].push( DragnDropUploadedFile.new("public" + name, "rb") )
    end 

    @test_session = MeegoTestSession.new(params[:meego_test_session])
    @test_session.import_report(current_user)
    
    if @test_session.save
      session[:preview_id] = @test_session.id

      redirect_to :controller => 'reports', :action => 'preview'
    else
      @release_versions = VersionLabel.all.map { |release| release.label }
      @targets = MeegoTestSession.targets
      @testtypes = MeegoTestSession.release(@selected_release_version).testtypes
      @hardware = MeegoTestSession.release(@selected_release_version).popular_hardwares
      render :upload_form
    end
  end
end
