class AddNotes < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :notes, :string
  end
end
