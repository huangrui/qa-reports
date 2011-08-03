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
    [:release_version, :target, :testset, :product].each do |key|
      new_report[key] = params[key] if params[key]
    end

    new_report[:release] = new_report[:release].downcase if new_report[:release]
    new_report[:target] ||= new_report[:target].downcase if new_report[:target]
    new_report[:target] ||= TargetLabel.targets.first.downcase
    @test_session = MeegoTestSession.new(new_report)
    @test_session.version_label = VersionLabel.find_by_label(new_report[:release_version]) || VersionLabel.latest

    @release_versions = VersionLabel.in_sort_order.map { |release| release.label }
    @targets = TargetLabel.targets.map {|target| target.downcase}
    @testsets = MeegoTestSession.release(@selected_release_version).testsets
    @product = MeegoTestSession.release(@selected_release_version).popular_products
    @build_id = MeegoTestSession.release(@selected_release_version).popular_build_ids

    @no_upload_link = true
  end

  def upload_report
    raw_filename = env['HTTP_X_FILE_NAME']
    raw_filename ||= request['qqfile'].original_filename if request['qqfile'].respond_to? 'original_filename'
    raw_filename ||= request['qqfile']
    extension = File.extname(raw_filename)
    raw_filename_wo_extension = File.basename(raw_filename, extension)

    # TODO: Temp files needs to be deleted periodically
    url      = "/reports/tmp/#{raw_filename_wo_extension.parameterize}#{extension}"
    filename = "#{Rails.root}/public#{url}"

    filedata = env['rack.input'].read()
    File.open(filename, 'wb') {|f| f.write( filedata ) }

    render :json => { :ok => '1', :url => url }
  end

  def upload_attachment
    file = StringIO.new(env['rack.input'].read())
    file.original_filename = request['qqfile']

    session = MeegoTestSession.find(params[:id])
    session.report_attachments.create(:attachment => file)
    @editing = true

    expire_caches_for(session)
    # full file name of template has to be given because flash uploader can pass header HTTP_ACCEPT: text/*
    # file is not found because render :formats=>[:"text/*"]
    html_content = render_to_string :partial => 'reports/file_attachment_list.html.slim', :locals => {:report => session, :files => session.report_attachments}
    render :json => { :ok => '1', :html_content => html_content}
  end

  def upload
    params[:meego_test_session][:uploaded_files] ||= []
    params[:drag_n_drop_attachments] ||= []

    # Harmonize file handling between drag'n drop and form upload
    params[:drag_n_drop_attachments].each do |name|
      params[:meego_test_session][:uploaded_files].push( DragnDropUploadedFile.new("public" + name, "rb") )
    end

    @test_session = ReportFactory.new.build(params[:meego_test_session])
    @test_session.author = current_user
    @test_session.editor = current_user
    
    if @test_session.errors.empty? and @test_session.save
      session[:preview_id] = @test_session.id

      redirect_to :controller => 'reports', :action => 'preview'
    else
      @release_versions = VersionLabel.all.map { |release| release.label }
      @targets = TargetLabel.targets
      @testsets = MeegoTestSession.release(@selected_release_version).testsets
      @product = MeegoTestSession.release(@selected_release_version).popular_products
      @build_id = MeegoTestSession.release(@selected_release_version).popular_build_ids
      render :upload_form
    end
  end
end
