#
# This file is part of meego-test-reports
#
# Copyright (C) 2011 Intel Corporation.
#
# Authors: Shao-Feng Tang <shaofeng.tang@intel.com>
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

require 'rubygems'
require 'nokogiri'
require 'file_storage'

class OptionalParamsParser

  @optional_param_names = ['build_txt', 'objective_txt', 'qa_summary_txt', 'issue_summary_txt']

  def self.parseOptionalParamsXml(session_model, dir, filename, title, errors)
    if ! session_model.optional_params_file 
      return nil
    end
   
    path_to_file = File.join(dir.path, filename)
    
    xml = File.open(path_to_file)
    doc = Nokogiri::XML(xml)

    report_params = doc.at_css('report')
    @optional_param_names.each do |name|
      assignOptionalParameters(session_model, report_params, name)
    end
    if !title
      if report_params.css('title')[0]
         session_model.update_attribute('title', report_params.css('title')[0].content)
      end
    end
  end 

  def self.assignOptionalParameters (session_model, report_params, optional_param_name)
    has_set = session_model.attribute_present?(optional_param_name)
    if !has_set and report_params.css(optional_param_name)[0]
        session_model.update_attribute(optional_param_name, report_params.css(optional_param_name)[0].content)
    end
  end

end
