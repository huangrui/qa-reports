class VersionLabel < ActiveRecord::Base
  def self.versions
    find(:all, :select => "normalized").map(&:normalized)
  end
end
