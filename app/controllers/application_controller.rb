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

class ApplicationController < ActionController::Base
  helper_method :release, :profile, :testset, :product
  before_filter :release

  #protect_from_forgery

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def record_not_found
    render :file => "#{Rails.root}/public/404.html", :status => :not_found, :layout => false
  end

  def release
    @release ||= Release.find_by_name(params[:release_version]) || Release.find_by_id(session[:release_id]) || Release.latest
    session[:release_id] = @release.id
    @release
  end

  def profile
    @profile ||= params[:target]
  end

  def testset
    @testset ||= params[:testset]
  end

  def product
    @product ||= params[:product]
  end

  private

  def valid_release release_version
    return unless release_version.present?
    return release_version if Release.all.map(&:name).include? release_version
    Rails.logger.info ["Info:  Invalid release version: ", release_version]
    nil
  end

end
