class Index

  def self.find_by_release(release)
    { :profiles => find_profiles(release) }
  end

  private 

  def self.find_profiles(release)
    TargetLabel.find_by_sql("
      SELECT DISTINCT profiles.label AS profile, reports.testset, reports.product AS name
      FROM meego_test_sessions AS reports
      JOIN target_labels AS profiles ON reports.target = profiles.normalized
      WHERE reports.release_id = #{release.id}
      ORDER BY profiles.sort_order ASC, testset, product
    ").group_by(&:profile).map do |profile, testsets|
      {
        :name     => profile,
        :url      => "#{release.name}/#{profile}",
        :testsets => testsets.group_by(&:testset).map do |testset, products|
            {
              :name     => testset,
              :url      => "#{release.name}/#{profile}/#{testset}",
              :products => products.map do |product|
                {
                  :name => product.name,
                  :url  => "#{release.name}/#{profile}/#{testset}/#{product.name}"
                }
              end
            }
          end
      }
    end
  end
end
