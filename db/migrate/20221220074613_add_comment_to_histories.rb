class AddCommentToHistories < ActiveRecord::Migration[7.0]
  def change
    add_column :histories, :comment, :string
  end
end
