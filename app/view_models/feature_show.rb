class FeatureShow < SummaryShow

  delegate :test_set_link, :name,
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
end