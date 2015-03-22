namespace :db do
  desc "Erase database and populate with test data"
  task :populate => :environment do


    [User, Course, Assignment, Membership].each(&:delete_all)

    # User creation
    @user = User.create!(name: 'foo', password: 'bar')
    @user2 = User.create!(name: 'hello', password: 'world')
    @admin = User.create(name: 'admin', password: 'admin', is_admin: true)

    # Courses
    @course = Course.create!(name: 'First Course')
    @course2 = Course.create!(name: 'Second Course')
    @course3 = Course.create!(name: 'Third Course')

    # @user is user in @course
    @user.memberships.create(course: @course, role_type: :is_user)
    # @user2 guest in @course
    @user2.memberships.create(course: @course, role_type: :is_guest)

    # Assignments
    @course.assignments.create(name: 'First assignment', description: 'This is the description of the first assignment')
    @course.assignments.create(name: 'Second assignment', description: 'This is the description of the second assignment')
  end
end