class AddIndexToEvents < ActiveRecord::Migration
  def change
    add_index :events, [:recurrence_day, :starts_at]
    add_index :events, [:starts_at, :kind]
  end
end
