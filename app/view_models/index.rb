class Index

  # Output
  # view_model =
  #   "release":"1.2"
  #   "profiles":[
  #     "name":"Handset"
  #     "testsets":[
  #       "name":"Sanity - Automated"
  #       "products":[
  #         "name":"N900"
  #       ]
  #       "name":"Acceptance"
  #       "products":[
  #         "name":"N900"
  #       ]
  #     ]
  #   ]

  def find(release)
    reports = MeegoTestSession.find_by_sql("
      SELECT DISTINCT profiles.label AS profile, reports.testset, reports.product 
      FROM meego_test_sessions AS reports
      JOIN target_labels AS profiles ON reports.target = profiles.normalized
      WHERE reports.release_id = #{release.id}
      ORDER BY profiles.sort_order ASC, testset, product
    ")

    model = {
      :release  => release.name,
      :profiles => []
    }

    profiles = reports.to_nested_hash [:profile, :testset], :map => :product, :unique => false

    reports.map(&:profile).each do | profile_name |
      model[:profiles] << {:name => profile_name}
    end

    model
  end

end
