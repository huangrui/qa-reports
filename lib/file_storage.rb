#
# This file is part of meego-test-reports
#
# Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
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
class FileStorage

  def initialize(dir = "public/files", baseurl = "/files/")
    @dir = dir
    @baseurl = baseurl
  end

  def get_params_file_path (model)
    get_directory(model)
  end

  def add_file(model, file, name)
    dir = get_directory(model, true)
    target = get_file_path(dir, name)
    FileUtils.copy(file.path, target)
    FileUtils.chmod(0755, target)
  end

  def remove_file(model, name)
    dir = get_directory(model)
    FileUtils.rm(get_file_path(dir, name))
  end

  def list_files(model)
    dir = get_directory(model, false)
    return [] if dir == nil
    Dir[File.join(dir.path, '*')].entries.sort{|a,b| File.ctime(a) - File.ctime(b) }.map{|file|
      path = file.slice(@dir.length+1, file.length)
      {   :name => File.basename(file),
          :path => path,
          :url => @baseurl + path
      }
    }
  end

  private
  def get_file_path(dir, name)
    dir.path + "/" + name.gsub(/[^0-9A-Za-z.\-_]/, '')
  end

  def get_directory(model, create = false)
    path = @dir + "/" + model.class.table_name + "/" + model.id.to_s + "/"
    if !File.directory?(path)
      if create
        FileUtils.mkdir_p(path, :mode => 0755)
      else
        return nil
      end
    end
    Dir.new(path)
  end  
end
