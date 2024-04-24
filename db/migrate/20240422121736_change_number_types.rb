class ChangeNumberTypes < ActiveRecord::Migration[7.1]
  def change
    change_column :customers, :previous_calls, :integer
    change_column :customers, :calls, :integer
  end
end
