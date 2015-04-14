class ListingAssignmentsTest < ActionDispatch::IntegrationTest

  def setup
    @user = User.create!(name: 'foo', password: 'bar')
    @user2 = User.create!(name: 'foo2', password: 'bar')
    @admin = User.create(name: 'admin', password: 'admin', is_admin: true)
    @course = Course.create!(name: 'First Course')
    # @user is user in @course
    @user.memberships.create(course: @course, role_type: :is_user)
    # @user2 guest in @course
    @user2.memberships.create(course: @course, role_type: :is_guest)
    @course.assignments.create(name: 'First assignment', description: 'This is the description of the first assignment')
    @course.assignments.create(name: 'Second assignment', description: 'This is the description of the second assignment')
  end

  test 'should get Assignments index' do
    get '/courses/1/assignments', {}, {'Authorization' => encode_credentials(@user.name, @user.password)}
    assert_equal 200, response.status
    refute_empty response.body
  end

  test 'should return 401 for Assignments when wrong credentials' do
    get '/courses/1/assignments', {}, {'Authorization' => encode_credentials(@user.name, 'WRONG_PASSWORD')}
    assert_equal 401, response.status
  end

  test 'should return Assignment by id' do
    assignment = @course.assignments.first
    # /courses/:course_id/assignments/:id
    get "/courses/#{@course.id}/assignments/#{assignment.id}", {}, {'Authorization' => encode_credentials(@user2.name, @user2.password)}
    assert_equal 200, response.status
    assignment_response = json(response.body)
    assert_equal assignment.name, assignment_response[:name]
  end

  # Create section
  test 'should create one assignment when admin' do
    post "/courses/#{@course.id}/assignments",
         {assignment:
              {name: 'Assignment #1', description: 'This is the description for assignment #1' }
         }.to_json,
         {'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s, 'Authorization' => encode_credentials(@admin.name, @admin.password)}

    assert_equal 201, response.status
    assert_equal Mime::JSON, response.content_type

    course = json(response.body)
    assert_equal v1_course_assignment_url(@course[:id], @course.assignments.last), response.location
  end

  test 'should create one assignment when user from this course' do
    post "/courses/#{@course.id}/assignments",
         {assignment:
              {name: 'Assignment #1', description: 'This is the description for assignment #1' }
         }.to_json,
         {'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s, 'Authorization' => encode_credentials(@user.name, @user.password)}

    assert_equal 201, response.status
    assert_equal Mime::JSON, response.content_type

    course = json(response.body)
    assert_equal v1_course_assignment_url(@course[:id], @course.assignments.last), response.location
  end

  test 'should NOT create one course when guest from this course' do
    post "/courses/#{@course.id}/assignments",
         {assignment:
              {name: 'Assignment #1', description: 'This is the description for assignment #1' }
         }.to_json,
         {'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s, 'Authorization' => encode_credentials(@user2.name, @user2.password)}
    assert_equal 403, response.status
  end

  # Update section
  test 'should have successful assignment update by admin' do
    patch "/courses/#{@course.id}/assignments/#{@course.assignments.first.id}",
          {assignment: {name: 'First Assignment Edit'}}.to_json,
          {'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s,
           'Authorization' => encode_credentials(@admin.name, @admin.password)}
    assert_equal 200, response.status
    assert_equal 'First Assignment Edit', @course.assignments.first.reload.name
  end

  test 'should have successful assignment update by user who is user for this course' do
    patch "/courses/#{@course.id}/assignments/#{@course.assignments.first.id}",
          {assignment: {name: 'First Assignment Edit'}}.to_json,
          {'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s,
           'Authorization' => encode_credentials(@user.name, @user.password)}
    assert_equal 200, response.status
    assert_equal 'First Assignment Edit', @course.assignments.first.reload.name
  end

  test 'should have unsuccesful assignment update (403) by user who is guest for this course' do
    patch "/courses/#{@course.id}/assignments/#{@course.assignments.first.id}",
          {assignment: {name: 'First Assignment Edit'}}.to_json,
          {'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s,
           'Authorization' => encode_credentials(@user2.name, @user2.password)}
    assert_equal 403, response.status
  end

  # Destroy section
  test 'should have successful assignment destroy by admin' do
    assert_difference('Assignment.count', -1) do
      delete "/courses/#{@course.id}/assignments/#{@course.assignments.first.id}", {}, {'Authorization' => encode_credentials(@admin.name, @admin.password)}
    end
    assert_equal 204, response.status
  end

  test 'should have successful assignment destroy by user who is user for this course' do
    assert_difference('Assignment.count', -1) do
      delete "/courses/#{@course.id}/assignments/#{@course.assignments.first.id}", {}, {'Authorization' => encode_credentials(@user.name, @user.password)}
    end
    assert_equal 204, response.status
  end

  test 'should have Unsuccesful assignment destroy (403) by user who is guest for this course' do
    assert_difference('Assignment.count', 0) do
      delete "/courses/#{@course.id}/assignments/#{@course.assignments.first.id}", {}, {'Authorization' => encode_credentials(@user2.name, @user2.password)}
    end
    assert_equal 403, response.status
  end


end