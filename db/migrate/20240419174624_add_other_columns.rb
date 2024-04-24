class AddOtherColumns < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :date_of_birth, :date
    add_column :customers, :job, :string
    add_column :customers, :marital, :string
    add_column :customers, :education, :string
    add_column :customers, :balance, :number
    add_column :customers, :default, :string
    add_column :customers, :housing, :string
    add_column :customers, :loan, :string
    add_column :customers, :calls, :number
    add_column :customers, :last_call, :date
    add_column :customers, :previous_calls, :number
    add_column :customers, :previous_outcome, :string
  end
end
