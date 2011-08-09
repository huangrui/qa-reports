class Product

  def self.by_profile_by_test_type(release)
    selection = <<-END
      DISTINCT target as profile, testset, product
    END

    @products = MeegoTestSession.published.select(selection).release(release).order(:target, :testset, :product)

    @products = @products.to_nested_hash [:profile, :testset], :map => :product, :unique => false

  end
end
