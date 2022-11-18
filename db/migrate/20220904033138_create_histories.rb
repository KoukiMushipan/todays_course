class CreateHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :histories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :destination, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.integer :moving_distance, null: false
      t.string :uuid, null: false

      t.index :uuid, unique: true
      t.timestamps
    end
  end
end
