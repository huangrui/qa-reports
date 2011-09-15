class Index

  # Output
  # view_model =
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
    {
      :profiles => [
        {
          :name => "Core"
        }
      ]
    }
    #Qlabels = TargetLabel.find(:all, :select => "normalized").map(&:normalized)
  end

end