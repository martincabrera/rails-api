class AssignmentPolicy < ApplicationPolicy

  def update?
    user.is_admin? || user.user_in_course?(record.course)
  end

  def destroy?
    update?
  end

  def create?
    user.is_admin? || user.user_in_course?(record.course)
  end

end