class VersionLabel < ActiveRecord::Base

  has_many :meego_test_sessions, :class_name => "MeegoTestSession"

  def self.versions
    find(:all, :select => "normalized").map(&:normalized)
  end
end
