class Product

  def self.by_profile_by_testset(release)
    selection = "DISTINCT profiles.label as profile, testset, product"
    products  = MeegoTestSession.published.joins(:profile).select(selection).release(release.name).order("profiles.label", :testset, :product)
    products.to_nested_hash [:profile, :testset], :map => :product, :unique => false
  end
end
