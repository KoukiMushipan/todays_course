class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :name, null: false, default: "未設定"
      t.float :latitude, null: false
      t.float :longitude, null: false
      t.string :address, null: false

      t.timestamps
    end
  end
end
