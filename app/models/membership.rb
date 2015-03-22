# == Schema Information
#
# Table name: memberships
#
#  id        :integer          not null, primary key
#  user_id   :integer
#  course_id :integer
#  role_type :integer          default(0)
#
# Indexes
#
#  index_memberships_on_course_id  (course_id)
#  index_memberships_on_user_id    (user_id)
#



class Membership < ActiveRecord::Base

  #validations
  validates :user_id, uniqueness: {scope: :course_id}

  #relations
  belongs_to :user
  belongs_to :course

  #scopes
  scope :by_course, -> (course) { where(course_id: Array(course).map(&:id))}
  scope :by_user, -> (user) { where(user_id: Array(user).map(&:id))}

  enum role_type: [ :is_user, :is_guest ]

  def self.by_course_and_user(course, user)
    return NullObject.new if course.nil? || user.nil?
    course = Array(course)
    by_user(user).by_course(course).first || NullObject.new
  end

  class NullObject
    def method_missing(*args, &block)
      false
    end
  end
end
