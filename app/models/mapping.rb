# Copyright (C) 2010 Intel Corporation
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# Authors:
#       Huang Rui  <rui.r.huang@intel.com>
# Date Created: 2012/02/27
#
# Modifications:
#          Modificator  Date
#          Content of Modification
#

class Mapping < ActiveRecord::Base
  belongs_to :profile

  def self.fetch_feature_mappings(component_name, case_name, profile_id)
    find(:all ,:conditions => ["feature = ? and test_case = ? and profile_id = ?", component_name, case_name, profile_id], :order => "id DESC")
  end

  def self.delete_feature_mappings(component_name, feature_name, case_name, profile_id)
    delete_all(["feature = ? and special_feature = ? and test_case = ? and profile_id = ?", component_name, feature_name, case_name, profile_id])
  end

end
