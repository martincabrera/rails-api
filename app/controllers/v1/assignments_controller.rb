class V1::AssignmentsController < ApplicationController


    before_action :find_course
    before_action :find_assignment, except: [:index, :create]

    def index
      assignments = Assignment.by_course(@course)
      render json: assignments, status: :ok
    end

    def create
      @assignment = @course.assignments.build(assignment_params)
      authorize @assignment
      if @assignment.save
        render json: @assignment, status: :created, location: v1_course_assignment_url(@assignment.course, @assignment)
      else
        render json: @assignment.errors, status: :unprocessable_entity
      end
    end

    def show
      render json: @assignment, status: :ok
    end

    def update
      authorize @assignment
      if @assignment.update(assignment_params)
        render json: @assignment, status: :ok
      else
        render json: @assignment.errors, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @assignment
      @assignment.destroy
      head :no_content
    end

    private

    def assignment_params
      params.require(:assignment).permit(:name, :description)
    end

    def find_course
      @course = Course.find(params[:course_id])
    end

    def find_assignment
      @assignment = Assignment.find(params[:id])
    end
  end
