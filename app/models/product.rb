class Product

  def self.by_profile_by_testset(release)
    selection = "DISTINCT profile.label as profile, testset, product"
    products  = MeegoTestSession.published.includes(:profile).select(selection).release(release.name).order({:profile => :label}, :testset, :product)
    products.to_nested_hash [:profile, :testset], :map => :product, :unique => false
  end
end
