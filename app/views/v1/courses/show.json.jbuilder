json.(@course, :name, :created_at, :updated_at)
json.assignments @course.assignments do |assignment|
  json.id assignment.id
  json.name assignment.name
  json.location v1_course_assignment_url(@course, assignment)
end