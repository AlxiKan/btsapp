class ChangeBalnceType < ActiveRecord::Migration[7.1]
  def change
    change_column :customers, :balance, :integer
  end
end
