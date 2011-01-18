# This file is part of qa-reports
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

class RssController < ApplicationController

  def rss
    @target = params[:target]
    @testtype = params[:testtype]
    @hwproduct = params[:hwproduct]

    unless MeegoTestSession.filters_exist?(@target, @testtype, @hwproduct)
      return render_404
    end

    if @hwproduct
      @sessions = MeegoTestSession.by_release_version_target_test_type_product(@selected_release_version, @target, @testtype, @hwproduct, "created_at DESC", 10)
    elsif @testtype
      @sessions = MeegoTestSession.published_by_release_version_target_test_type(@selected_release_version, @target, @testtype, "created_at DESC", 10)
    elsif @target
      @sessions = MeegoTestSession.published_by_release_version_target(@selected_release_version, @target, "created_at DESC", 10)
    else
      @sessions = MeegoTestSession.published_by_release_version(@selected_release_version, "created_at DESC", 10)
    end

    render :layout => false
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end

end
