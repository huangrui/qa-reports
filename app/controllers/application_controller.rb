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

  before_filter :find_releases
  before_filter :find_selected_release

  #protect_from_forgery

  def find_releases
    @meego_releases = VersionLabel.release_versions
  end

  def find_selected_release
    @selected_release_version = session[:release_version] =
      valid_version_label(params[:release_version]) || session[:release_version] || VersionLabel.latest.label
  end

  def render_404
    render :file => "#{Rails.root}/public/404.html", :status => :not_found, :layout => false
  end

  private
  
  def valid_version_label release_version
    return unless release_version.present?

    if VersionLabel.all.map(&:normalized).include? release_version.downcase
      release_version
    else
      Rails.logger.info ["Info:  Invalid release version: ", release_version]
      return nil
    end
  end

end
