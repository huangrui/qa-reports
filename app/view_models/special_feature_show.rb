class SpecialFeatureShow < SummaryShow

  delegate :name,
           :to => :@special_feature

  def initialize(feature, build_diff=[])
    @special_feature = feature
    super(@special_feature, build_diff)
  end
end
