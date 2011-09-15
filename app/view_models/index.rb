class Index

  def self.find_by_release(release)
    model = {} 
    model[:release]  = release.name
    model[:profiles] = TargetLabel.select("label AS name").order("sort_order ASC").map do |profile|
      {
        :name     => profile.name,
        :url      => "#{release.name}/#{profile.name}",
        :testsets => MeegoTestSession.release(release.name).profile(profile.name).
          select("DISTINCT testset AS name").order(:testset).map do |testset|
            {
              :name     => testset.name,
              :url      => "#{release.name}/#{profile.name}/#{testset.name}",
              :products => MeegoTestSession.release(release.name).profile(profile.name).testset(testset.name).
                select("DISTINCT product AS name").order(:product).map do |product|
                {
                  :name => product.name,
                  :url  => "#{release.name}/#{profile.name}/#{testset.name}/#{product.name}"
                }
              end
            }
          end
      }
    end

    model
  end
end
