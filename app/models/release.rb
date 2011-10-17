class Release < ActiveRecord::Base

  scope :in_sort_order, order("sort_order ASC")

  def self.names
    in_sort_order.map(&:name)
  end

  def self.latest
    in_sort_order.first
  end

end
