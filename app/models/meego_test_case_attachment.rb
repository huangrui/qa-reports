class MeegoTestCaseAttachment < ActiveRecord::Base
	belongs_to :meego_test_case
	validates_presence_of :meego_test_case

	has_attached_file :attachment
    #, :url => "/attachments/:basename.:extension?:id"
    #, :path => ":rails_root/public/system/:attachment/:id/:style/:filename"
end
