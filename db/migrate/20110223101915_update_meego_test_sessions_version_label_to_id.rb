class UpdateMeegoTestSessionsVersionLabelToId < ActiveRecord::Migration
  def self.up
    sessions = MeegoTestSession.find(:all)
    targets = VersionLabel.find(:all)
    sessions.each do |s|
      targets.each do |t|
        puts s.release_version
        puts t.label
        if s.release_version.eql? t.label
          s.release_version = t.id
        end
      end
      s.save()
    end
  end

  def self.down
  end
end
