class MigrateReleaseVersionToVerionValue < ActiveRecord::Migration
  def self.up
    sessions = MeegoTestSession.find(:all)
    targets = VersionLabel.find(:all)
    sessions.each do |s|
      targets.each do |t|
        if s.release_version == t.id
          s.version_value = t.label
        end
      end
      s.save()
    end
  end

  def self.down
    sessions = MeegoTestSession.find(:all)
    targets = VersionLabel.find(:all)
    sessions.each do |s|
      targets.each do |t|
        if s.version_value == t.label
          s.release_version = t.id
        end
      end
      s.save()
    end
  end
end
