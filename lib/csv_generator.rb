module CsvGenerator
  def self.generate_csv(release_version, target, testtype, hardware)
    sql = <<-END
      select mts.tested_at, vl.label, mts.target, mts.testtype, mts.hardware, mts.title,
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
    conditions << "mtc.deleted = false"
    conditions << "mts.hardware = '#{hardware}'" if hardware
    conditions << "mts.target = '#{target}'" if target
    conditions << "mts.testtype = '#{testtype}'" if testtype
    conditions << "vl.normalized = '#{release_version.downcase}'" if release_version

    sql += " where " + conditions.join(" and ") + ";"

    result = ActiveRecord::Base.connection.execute(sql)

    FasterCSV.generate(:col_sep => ';') do |csv|
      csv << ["Test execution date",
              "MeeGo release",
              "Profile",
              "Test set",
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

  def self.generate_csv_report(release_version, target, testtype, hardware, id)
    sql = <<-END
      select mtset.feature, mtc.name, mtc.comment,
        if(mtc.result = 1,1,null) as pass,
        if(mtc.result = -1,1,null) as fail,
        if(mtc.result = 0,1,null) as na
      from meego_test_sets as mtset
        join meego_test_cases as mtc on (mtc.meego_test_set_id = mtset.id)
        join meego_test_sessions as mts on (mtc.meego_test_session_id = mts.id)
      where mts.id = '#{id}' and mtc.deleted = false
      order by mtset.id, mtc.id;
    END

    result = ActiveRecord::Base.connection.execute(sql)

    FasterCSV.generate(:col_sep => ',') do |csv|
      csv << ["Feature",
        "Check points",
        "Notes (bugs)",
        "Pass",
        "Fail",
        "N/A"
      ]

      result.each do |row|
        csv << row
      end
    end
  end
end
