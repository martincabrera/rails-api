# == Schema Information
#
# Table name: assignments
#
#  id          :integer          not null, primary key
#  course_id   :integer
#  name        :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_assignments_on_course_id  (course_id)
#

class Assignment < ActiveRecord::Base

  #relations
  belongs_to :course

  #scopes
  scope :by_course, -> (course) { where(course_id: Array(course).map(&:id))}
end
