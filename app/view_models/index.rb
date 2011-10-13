class Index

  CUT_OFF_LIMIT = 30

  def self.find_profiles(release, show_all)
    { :profiles => Profile.find_by_sql("
        SELECT DISTINCT profiles.label AS profile, reports.testset, reports.product AS name
        FROM profiles
        LEFT JOIN meego_test_sessions AS reports ON profiles.id = reports.profile_id AND
          reports.release_id = #{release.id} AND
          reports.published  = TRUE AND
          reports.tested_at  > '#{show_all ? 0 : CUT_OFF_LIMIT.days.ago}'
        ORDER BY profiles.sort_order ASC, testset, product
      ").group_by(&:profile).map do |profile, testsets|
        {
          :name     => profile,
          :url      => "/#{release.name}/#{profile}",
          :testsets => testsets.first.testset.nil? ? [] : testsets.group_by(&:testset).map do |testset, products|
              {
                :name           => testset,
                :url            => "/#{release.name}/#{profile}/#{testset}",
                :comparison_url => comparison_url(release, profile, testset),
                :products       => products.map do |product|
                  {
                    :name => product.name,
                    :url  => "/#{release.name}/#{profile}/#{testset}/#{product.name}"
                  }
                end
              }
            end
        }
      end
    }
  end

  def self.comparison_url(release, profile, testset)
    testset_base   = testset.split(":")[0]
    comparetype    = testset_base + ":Testing"
    comparison_url = "/#{release.name}/#{profile}/#{testset_base}/compare/#{comparetype}"
    comparison_url if MeegoTestSession.release(release.name).profile(profile).testset(comparetype.capitalize).count > 0
  end
end
