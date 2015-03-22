class CoursePolicy < ApplicationPolicy

  def create?
    user.is_admin?
  end

  def update?
    user.is_admin? || user.user_in_course?(record)
  end

  def destroy?
    update?
  end

end