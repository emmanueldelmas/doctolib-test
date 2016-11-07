# == Schema Information
#
# Table name: events
#
#  id               :integer          not null, primary key
#  starts_at        :datetime
#  ends_at          :datetime
#  kind             :string
#  weekly_recurring :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Event < ActiveRecord::Base
end
