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

module IndexHelper

  def current_filter_path
    path = @target
    path += " / #{@testset}" if @testset.present?
    path += " / #{@product}" if @product.present?
    path
  end

  def filtered_index_url(target, testset=nil, product=nil)
    url_for(:controller=>'ReportGroupsController', :action=>'show', :release_version=>@selected_release_version, :target=>target, :testset=>testset, :product=>product)
  end

end

