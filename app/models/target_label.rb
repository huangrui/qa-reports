class TargetLabel < ActiveRecord::Base
  def self.labels
    find(:all, :select => "normalized").map(&:normalized)
  end
end
