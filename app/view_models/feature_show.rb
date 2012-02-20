class FeatureShow < SummaryShow

  delegate :comments, :grading, :name, :test_set_link,
           :to => :@feature

  def initialize(feature, build_diff=[])
    @feature = feature
    super(@feature, build_diff)
  end

  def history(method)
    method.map do |report|
      feature = @feature.find_matching_feature report
      FeatureShow.new(feature) unless feature.nil?
    end
  end

  def graph_img_tag(max_cases)
    @feature.html_graph total_passed, total_failed, total_na, max_cases
  end

  def special_features
    @special_features ||= @feature.special_features.map { |special_feature| SpecialFeatureShow.new(special_feature, @build_diff) }
  end

end
