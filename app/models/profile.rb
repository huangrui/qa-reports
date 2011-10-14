class Profile < ActiveRecord::Base
  def self.names
    order("sort_order ASC").select(:name).map(&:name)
  end

  def self.first
    order("sort_order ASC").first
  end
end
