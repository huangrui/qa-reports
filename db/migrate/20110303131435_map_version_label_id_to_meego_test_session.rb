class MapVersionLabelIdToMeegoTestSession < ActiveRecord::Migration
  def self.up
    sessions = MeegoTestSession.find(:all)
    targets = VersionLabel.find(:all)
    sessions.each do |s|
      targets.each do |t|
        if s.release_version == t.label
          s.version_label_id = t.id
        end
      end
      s.save()
    end
  end

  def self.down
  end
end
