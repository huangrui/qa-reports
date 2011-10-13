class Profile < ActiveRecord::Base
  def self.names
    order("sort_order ASC").select(:label).map(&:label)
  end

  def self.labels
    find(:all, :select => "normalized").map(&:normalized)
  end

  def self.first
    order("sort_order ASC").first
  end
end
