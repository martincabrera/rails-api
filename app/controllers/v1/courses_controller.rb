class V1::CoursesController < ApplicationController

  before_action :find_course, except: [:index, :create]

  def index
    courses = Course.all
    render json: courses, status: :ok
  end

  def create
    course = Course.new(course_params)
    authorize course
    if course.save
      render json: course, status: :created, location: v1_course_url(course)
    else
      render json: course.errors, status: :unprocessable_entity
    end

  end

  def show

  end

  def update
    authorize @course
    if @course.update(course_params)
      render json: @course, status: :ok
    else
      render json: @course.errors, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @course
    @course.destroy
    head :no_content
  end

  private

  def course_params
    params.require(:course).permit(:name)
  end

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Token realm="Courses"'
    render json: 'Bad credentials', status: :unauthorized
  end

  def find_course
    @course = Course.find(params[:id])
  end

end
