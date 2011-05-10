#
# This file is part of meego-test-reports
#
# Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
#
# Authors: Toni Jyrkinen <toni.jyrkinen@leonidasoy.fi>
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

class MeegoTestCaseAttachment < ActiveRecord::Base
	belongs_to :meego_test_case
	validates_presence_of :meego_test_case

	has_attached_file :attachment
    # TODO: make the nicer version of URL work
    #, :url => "/attachments/:basename.:extension?:id"
    #, :path => ":rails_root/public/system/:attachment/:id/:style/:filename"

  def image?
    (attachment.url =~ /(jpg|jpeg|gif|png|bmp)/) if attachment.present?
  end

  def filename
    attachment.url.split('/').last.split('?').first if attachment.present?
  end

  def resource
    attachment
  end

end
