class Hardware

  def self.by_profile_by_test_type(release)
    selection = <<-END
      DISTINCT target as profile, testtype, hwproduct as hardware
    END

    @hardwares = MeegoTestSession.published.select(selection).joins(:version_label).
      where(:version_labels => {:normalized => release.downcase})

    @hardwares = @hardwares.group_by(&:profile)

    @hardwares.each do |profile, hardwares_by_profile|
      @hardwares[profile] = hardwares_by_profile.group_by(&:testtype)
    end

    @hardwares.each do |profile, hardwares|
      @hardwares[profile].each do |testtype, hardwares|
        @hardwares[profile][testtype] = hardwares.map(&:hardware)
      end
    end

    @hardwares
  end
end