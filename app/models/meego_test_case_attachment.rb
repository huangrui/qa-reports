class MeegoTestCaseAttachment < ActiveRecord::Base
	belongs_to :meego_test_case

	has_attached_file :image
end
