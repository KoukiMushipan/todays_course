class CreateDestinations < ActiveRecord::Migration[7.0]
  def change
    create_table :destinations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.references :departure, null: false, foreign_key: true
      t.integer :distance, null: false
      t.boolean :is_saved, null: false, default: false
      t.string :uuid, null: false

      t.index :uuid, unique: true
      t.timestamps
    end
  end
end
