class CreateCandidates < ActiveRecord::Migration[7.2]
  def change
    create_table :candidates do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :gender
      t.string :location
      t.integer :experience_years
      t.string :education
      t.string :skills
      t.string :domain
      t.string :current_employer
      t.string :fit_rating
      t.text :summary

      t.timestamps
    end
  end
end
