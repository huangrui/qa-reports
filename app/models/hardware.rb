class Hardware

  def self.by_profile_by_test_type(release)
    selection = <<-END
      DISTINCT target as profile, testset, hardware as hardware
    END

    @hardwares = MeegoTestSession.published.select(selection).joins(:version_label).
      where(:version_labels => {:normalized => release.downcase}).order(:testset, :hardware)

    @hardwares = @hardwares.group_by(&:profile)

    @hardwares.each do |profile, hardwares_by_profile|
      @hardwares[profile] = hardwares_by_profile.group_by(&:testset)
    end

    @hardwares.each do |profile, hardwares|
      @hardwares[profile].each do |testset, hardwares|
        @hardwares[profile][testset] = hardwares.map(&:hardware)
      end
    end

    @hardwares
  end
end