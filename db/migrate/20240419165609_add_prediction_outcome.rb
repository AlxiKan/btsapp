class AddPredictionOutcome < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :prediction, :string
    add_column :customers, :outcome, :string
  end
end
