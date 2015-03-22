class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.references :course, index: true
      t.string :name
      t.text :description

      t.timestamps null: false
    end
    add_foreign_key :assignments, :courses
  end
end
