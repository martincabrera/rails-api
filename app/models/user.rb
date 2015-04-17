# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string
#  is_admin        :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string
#

class User < ActiveRecord::Base

  has_secure_password

  #relations
  has_many :memberships, dependent: :delete_all
  has_many :courses, through: :memberships

  def admin?
    is_admin
  end

  def user_in_course?(course)
    Membership.by_course_and_user(course, self).is_user?
  end

  def guest_in_course?(course)
    Membership.by_course_and_user(course, self).is_guest?
  end


end
