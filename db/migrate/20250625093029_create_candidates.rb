class CreateCandidates < ActiveRecord::Migration[7.2]
  def change
    create_table :candidates do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :gender
      t.string :location
      t.float :experience_years
      t.text :education
      t.text :skills
      t.text :domain
      t.text :current_employer
      t.text :work_experience
      t.string :fit_rating
      t.text :summary

      t.timestamps
    end
  end
end
