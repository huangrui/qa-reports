class SpecialFeatureShow < SummaryShow

  delegate :name,
           :to => :@special_feature

  def initialize(feature, build_diff=[])
    @special_feature = feature
    super(@special_feature, build_diff)
  end

  def history(method)
    method.map do |report|
      feature = @special_feature.find_matching_special_feature report
      SpecialFeatureShow.new(feature) unless feature.nil?
    end
  end

  def graph_img_tag(max_cases)
    @special_feature.html_graph total_passed, total_failed, total_na, max_cases
  end
end
