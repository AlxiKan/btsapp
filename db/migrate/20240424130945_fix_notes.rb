class FixNotes < ActiveRecord::Migration[7.1]
  def change
    change_column :customers, :notes, :text
  end
end
