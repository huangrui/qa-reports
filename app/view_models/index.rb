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
    model = {
      :release  => release.name,
      :profiles => []
    }

    profiles = TargetLabel.select("label AS name").order("sort_order ASC").all
    profiles.each do |profile|
      profile_hash = profile.attributes
      testsets = MeegoTestSession.release(release.name).profile(profile.name).select("DISTINCT testset AS name").order(:testset)
      profile_hash[:testsets] = testsets.map &:attributes
      model[:profiles] << profile_hash
    end

    model
  end

end
