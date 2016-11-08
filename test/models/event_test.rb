# == Schema Information
#
# Table name: events
#
#  id             :integer          not null, primary key
#  starts_at      :datetime         not null
#  ends_at        :datetime         not null
#  kind           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  recurrence_day :integer
#

require 'test_helper'

class EventTest < ActiveSupport::TestCase
    
  test "one simple test example" do
    
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal Date.new(2014, 8, 16), availabilities[6][:date]
    assert_equal 7, availabilities.length
  end
  
  test "if one-time event present for selected day" do
    # S'il existe des horaires d'ouvertures ponctuels sur un jour,
    # on ne prend pas en compte les évènements récurrents précédents.
    Event.create!(kind: 'opening', starts_at: DateTime.parse("2014-08-04 10:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true)
    Event.create!(kind: 'opening', starts_at: DateTime.parse("2014-08-04 13:30"), ends_at: DateTime.parse("2014-08-04 15:00"), weekly_recurring: true)
    
    Event.create!(kind: 'opening', starts_at: DateTime.parse("2014-08-25 11:30"), ends_at: DateTime.parse("2014-08-25 12:30"))
    Event.create!(kind: 'opening', starts_at: DateTime.parse("2014-08-25 14:00"), ends_at: DateTime.parse("2014-08-25 15:30"), weekly_recurring: true)

    availabilities = Event.availabilities( DateTime.parse("2014-08-11"))
    assert_equal ["10:30", "11:00", "11:30", "12:00", "13:30", "14:00", "14:30"], availabilities[0][:slots]
    
    # Uniquement les évènements récurrents du 2014-08-25 sont pris en compte
    availabilities = Event.availabilities( DateTime.parse("2014-08-25"))
    assert_equal ["11:30", "12:00", "14:00", "14:30", "15:00"], availabilities[0][:slots]
  end
  
  test "only use last recurrence date" do
    # S'il n'y a pas d'horaire d'ouverture ponctuel sur un jour,
    # on prend en compte les évènements récurrents de la date la plus proche qui précèdent ce jour.
    # La date doit correspondre au même jour de la semaine.
    #
    # Ainsi, les évènements récurrents ont un effet jusqu'à la date ultérieur du même jour de la semaine,
    # pour laquelle un nouvel évènement récurrent est mis en place.
    #
    Event.create!(kind: 'opening', starts_at: DateTime.parse("2014-08-25 11:30"), ends_at: DateTime.parse("2014-08-25 12:30"), weekly_recurring: true)
    Event.create!(kind: 'opening', starts_at: DateTime.parse("2014-08-25 14:00"), ends_at: DateTime.parse("2014-08-25 15:30"), weekly_recurring: true)

    Event.create!(kind: 'opening', starts_at: DateTime.parse("2014-08-04 10:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true)
    Event.create!(kind: 'opening', starts_at: DateTime.parse("2014-08-04 13:30"), ends_at: DateTime.parse("2014-08-04 15:00"), weekly_recurring: true)
    
    availabilities = Event.availabilities( DateTime.parse("2014-08-11"))
    assert_equal ["10:30", "11:00", "11:30", "12:00", "13:30", "14:00", "14:30"], availabilities[0][:slots]
    
    # Uniquement les évènements récurrents du 2014-08-25 sont pris en compte
    availabilities = Event.availabilities( DateTime.parse("2014-09-01"))
    assert_equal ["11:30", "12:00", "14:00", "14:30", "15:00"], availabilities[0][:slots]
  end
  
  test "can't create appointment out of opening slot" do
    Event.create!(kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true)
    Event.create!(kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30"))
    assert_raise { Event.create!(kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")) }
    assert_raise { Event.create!(kind: 'appointment', starts_at: DateTime.parse("2014-08-25 13:30"), ends_at: DateTime.parse("2014-08-25 14:00")) }
  end
  
end
