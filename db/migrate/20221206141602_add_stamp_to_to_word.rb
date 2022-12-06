class AddStampToToWord < ActiveRecord::Migration[7.0]
  def change
    add_column :words, :stamp, :integer, null: false, default: 0
  end
end
