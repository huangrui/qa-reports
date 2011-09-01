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
    @target   = params[:target]
    @testset = params[:testset]
    @product = params[:product]

    unless MeegoTestSession.filters_exist?(@target, @testset, @product)
      return render_404
    end

    if @product
      @sessions = MeegoTestSession.by_release_version_target_testset_product(release.name, @target, @testset, @product, "created_at DESC", 10)
    elsif @testset
      @sessions = MeegoTestSession.published_by_release_version_target_testset(release.name, @target, @testset, "created_at DESC", 10)
    elsif @target
      @sessions = MeegoTestSession.published_by_release_version_target(release.name, @target, "created_at DESC", 10)
    else
      @sessions = MeegoTestSession.published_by_release_version(release.name, "created_at DESC", 10)
    end

    render :layout => false
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end

end
