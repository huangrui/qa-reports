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
module CsvGenerator
  def self.generate_csv(release_version, target, testtype, hwproduct)
    sql = <<-END
      select mts.tested_at, vl.label, mts.target, mts.testtype, mts.hwproduct, mts.title,
        mtset.feature, mtc.name, if(mtc.result = 1,1,0) as passes, if(mtc.result = -1,1,0) as fails,
        if(mtc.result = 0,1,0) as nas, mtc.comment, author.name, editor.name
      from meego_test_sessions mts
        join users as author on (mts.author_id = author.id)
        join users as editor on (mts.editor_id = editor.id)
        join meego_test_cases as mtc on (mtc.meego_test_session_id = mts.id)
        join meego_test_sets as mtset on (mtc.meego_test_set_id = mtset.id)
        join version_labels as vl on (mts.version_label_id = vl.id)
    END

    conditions = []
    conditions << "mts.published = true"
    conditions << "mts.hwproduct = '#{hwproduct}'" if hwproduct
    conditions << "mts.target = '#{target}'" if target
    conditions << "mts.testtype = '#{testtype}'" if testtype
    conditions << "vl.normalized = '#{release_version.downcase}'" if release_version

    sql += " where " + conditions.join(" and ") + ";"

    result = ActiveRecord::Base.connection.execute(sql)

    FasterCSV.generate(:col_sep => ';') do |csv|
      csv << ["Test execution date",
              "MeeGo release",
              "Profile",
              "Test type",
              "Hardware",
              "Test report name",
              "Feature",
              "Test case",
              "Pass",
              "Fail",
              "N/A",
              "Notes",
              "Author",
              "Last modified by"
      ]

      result.each do |row|
        csv << row
      end
    end
  end
end
