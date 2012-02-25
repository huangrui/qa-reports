class SpecialFeatureShow < SummaryShow

  delegate :name,
           :to => :@special_feature

  def initialize(feature, build_diff=[])
    @special_feature = feature
    super(@special_feature, build_diff)
  end

  def graph_img_tag(max_cases)
    @special_feature.html_graph total_passed, total_failed, total_na, max_cases
  end
end
