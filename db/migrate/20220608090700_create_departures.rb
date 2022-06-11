class CreateDepartures < ActiveRecord::Migration[7.0]
  def change
    create_table :departures do |t|
      t.references :user, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.boolean :is_saved, null: false, default: false

      t.timestamps
    end
  end
end
