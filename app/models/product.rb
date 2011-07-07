class Product

  def self.by_profile_by_test_type(release)
    selection = <<-END
      DISTINCT target as profile, testset, product
    END

    @products = MeegoTestSession.published.select(selection).joins(:version_label).
      where(:version_labels => {:normalized => release.downcase}).order(:testset, :product)

    @products = @products.group_by(&:profile)

    @products.each do |profile, products_by_profile|
      @products[profile] = products_by_profile.group_by(&:testset)
    end

    @products.each do |profile, products|
      @products[profile].each do |testset, products|
        @products[profile][testset] = products.map(&:product)
      end
    end

    @products
  end
end
