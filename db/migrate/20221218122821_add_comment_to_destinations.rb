class AddCommentToDestinations < ActiveRecord::Migration[7.0]
  def change
    add_column :destinations, :comment, :string
    add_column :destinations, :is_published_comment, :boolean, null: false, default: false
  end
end
