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

class Event < ActiveRecord::Base
  
  attr_accessor :weekly_recurring
  
  KIND = [
    OPENING = 'opening',
    APPOINTMENT = 'appointment'
  ].freeze
  enum days: [
    :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday
  ]
  
  SLOT_DURATION = 30
  
  before_validation :set_recurrence_day
  
  validates_presence_of :starts_at, :ends_at, :kind
  validates_inclusion_of :kind, in: KIND
  validates_inclusion_of :recurrence_day, in: days.values, allow_nil: true
  
  scope :openings, -> { where(kind: OPENING) }
  scope :appointments, -> { where(kind: APPOINTMENT) }
  scope :recurrent, -> (day) { where(recurrence_day: day) }
  scope :starts_on, -> (date) {
    date ? where(starts_at: (date.beginning_of_day..date.end_of_day)) : none
  }
  
  class << self
    
    # Get availabilities for next 7 days.
    def availabilities(date)
      availabilities = []
    
      while availabilities.size < 7 do
        availabilities << availabilities_for(date + availabilities.size.day)
      end
    
      availabilities
    end
  
    # Get availabilities for given day
    def availabilities_for(date)
      openings_slots = openings_on(date).collect(&:slots).flatten
      appointments_slots = appointments_on(date).collect(&:slots).flatten
    
      {
        date: date,
        slots: openings_slots - appointments_slots
      }
    end
  
    # Get openings on given day
    def openings_on(date)
      events = openings.starts_on(date).to_a
      events.present? ? events : recurrent_openings_for(date)
    end
  
    # Get reccurent openings for given day
    def recurrent_openings_for(date)
      query = openings.recurrent(date.wday)
      recurrence_date = query.where("starts_at < ?", date).maximum(:starts_at)
      recurrence_date ? query.starts_on(recurrence_date).to_a : []
    end
  
    # Get appointments on given day
    def appointments_on(date)
      appointments.starts_on(date).to_a
    end
    
  end
  
  def slots
    return @slots if @slots
    
    @slots = []
    slot = starts_at
    
    while slot < ends_at do 
      @slots << slot.strftime("%k:%M").strip
      slot = slot.advance(minutes: SLOT_DURATION)
    end
    
    @slots
  end
  
  private
  
  def set_recurrence_day
    if weekly_recurring
      self.weekly_recurring = nil
      self.recurrence_day = starts_at.wday
    end
  end
  
end
