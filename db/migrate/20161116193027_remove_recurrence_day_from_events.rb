class RemoveRecurrenceDayFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :recurrence_day
    add_index :events, [:weekly_recurring, :kind, :starts_at]
  end
end
