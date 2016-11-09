class AddWeeklyRecurringToEvents < ActiveRecord::Migration
  def change
    add_column :events, :weekly_recurring, :boolean
  end
end
