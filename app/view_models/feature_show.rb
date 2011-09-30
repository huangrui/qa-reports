class FeatureShow < SummaryShow

  delegate :comments, :grading, :id, :name, :test_set_link,
           :to => :@feature

  def initialize(feature)
    @feature = feature
    super(@feature)
  end

  def history
    @feature.build_diff.map(&:find_matching_feature).map do |feature|
      FeatureShow.new(feature) unless feature.nil?
    end
  end

  def graph_img_tag(max_cases)
    @feature.html_graph total_passed, total_failed, total_na, max_cases
  end
end
