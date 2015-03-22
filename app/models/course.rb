# == Schema Information
#
# Table name: courses
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Course < ActiveRecord::Base

  #validations
  validates :name, presence: true

  #relations
  has_many :assignments, dependent: :destroy

end
