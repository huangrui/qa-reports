class Product

  def self.by_profile_by_testset(release)
    selection = "DISTINCT target as profile, testset, product"
    reports  = MeegoTestSession.published.select(selection).release(release.name).order(:target, :testset, :product).all
    profiles = reports.to_nested_hash [:profile, :testset], :map => :product, :unique => false
    profiles = profiles.map do |profile, testsets|
      {
        :name     => profile.capitalize,
        :testsets => testsets.map do |testset, products|
          {
            :name     => testset,
            :products => products.map do |product|
              { :name => product.capitalize }
            end
          }
        end
      }
    end
  end
end
