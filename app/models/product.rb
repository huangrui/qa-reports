class Product

  def self.by_profile_by_testset(release)
    selection = "DISTINCT target as profile, testset, product"
    products  = MeegoTestSession.published.select(selection).release(release.label).order(:target, :testset, :product)
    products.to_nested_hash [:profile, :testset], :map => :product, :unique => false
  end
end
