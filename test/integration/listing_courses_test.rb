class ListingCoursesTest < ActionDispatch::IntegrationTest

  def setup
    @user = User.create!(name: 'foo', password: 'bar')
    @user2 = User.create!(name: 'foo2', password: 'bar')
    @admin = User.create(name: 'admin', password: 'admin', is_admin: true)
    @course = Course.create!(name: 'First Course')
    # @user is use in @course
    @user.memberships.create(course: @course, role_type: :is_user)
    # @user2 guest in @course
    @user2.memberships.create(course: @course, role_type: :is_guest)
  end

  test 'should get Courses index' do
    get '/courses', {}, {'Authorization' => encode_credentials(@user.name, @user.password)}
    assert_equal 200, response.status
    refute_empty response.body
  end

  test 'should return 401 ' do
    get '/courses', {}, {'Authorization' => encode_credentials(@user.name, 'WRONG_PASSWORD')}
    assert_equal 401, response.status
  end

  test 'should return course by id' do
    course = Course.create!(name: 'JavaScript stinks!')
    get "/courses/#{course.id}", {}, {'Authorization' => encode_credentials(@user.name, @user.password)}
    assert_equal 200, response.status
    course_response = json(response.body)
    assert_equal course.name, course_response[:name]
  end

  # Create section
  test 'should create one course when admin' do
    post '/courses',

         {course:
              {name: 'PHP'}
         }.to_json,
         {'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s, 'Authorization' => encode_credentials(@admin.name, @admin.password)}

    assert_equal 201, response.status
    assert_equal Mime::JSON, response.content_type

    course = json(response.body)
    assert_equal v1_course_url(course[:id]), response.location
  end

  test 'should NOT create one course when NOT admin' do
    post '/courses',
         {course:
              {name: 'PHP'}
         }.to_json,
         {'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s, 'Authorization' => encode_credentials(@user.name, @user.password)}
    assert_equal 403, response.status
  end

  # Update section
  test 'should have successful update by admin' do
    patch "/courses/#{@course.id}",
          {course: {name: 'First Course Edit'}}.to_json,
          {'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s,
           'Authorization' => encode_credentials(@admin.name, @admin.password)}
    assert_equal 200, response.status
    assert_equal 'First Course Edit', @course.reload.name
  end

  test 'should have successful update by user who is user for this course' do
    patch "/courses/#{@course.id}",
          {course: {name: 'First Course Edit'}}.to_json,
          {'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s,
           'Authorization' => encode_credentials(@user.name, @user.password)}
    assert_equal 200, response.status
    assert_equal 'First Course Edit', @course.reload.name
  end

  test 'should have Unsuccesful update (403) by user who is guest for this course' do
    patch "/courses/#{@course.id}",
          {course: {name: 'First Course Edit'}}.to_json,
          {'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s,
           'Authorization' => encode_credentials(@user2.name, @user2.password)}
    assert_equal 403, response.status
  end

  # Destroy section
  test 'should have successful destroy by admin' do
    delete "/courses/#{@course.id}", {}, {'Authorization' => encode_credentials(@admin.name, @admin.password)}
    assert_equal 204, response.status
  end

  test 'should have successful destroy by user who is user for this course' do
    delete "/courses/#{@course.id}", {}, {'Authorization' => encode_credentials(@user.name, @user.password)}
    assert_equal 204, response.status
  end

  test 'should have Unsuccesful destroy (403) by user who is guest for this course' do
    delete "/courses/#{@course.id}", {}, {'Authorization' => encode_credentials(@user2.name, @user2.password)}
    assert_equal 403, response.status
  end


end