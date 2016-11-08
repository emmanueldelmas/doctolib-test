class AddRecurrenceDayToEvents < ActiveRecord::Migration
  def change
    change_column :events, :starts_at, :datetime, null: false
    change_column :events, :ends_at, :datetime, null: false
    change_column :events, :kind, :string, null: false
    add_column :events, :recurrence_day, :integer
    remove_column :events, :weekly_recurring
  end
end
