# == Schema Information
#
# Table name: events
#
#  id               :integer          not null, primary key
#  starts_at        :datetime         not null
#  ends_at          :datetime         not null
#  kind             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  weekly_recurring :boolean
#

class Event < ActiveRecord::Base
  
  KIND = [
    OPENING = 'opening',
    APPOINTMENT = 'appointment'
  ].freeze
  
  SLOT_DURATION = 30
  
  validates_presence_of :starts_at, :ends_at, :kind
  validates_inclusion_of :kind, in: KIND
  validate :validate_opening_slot, if: :appointment?
  
  scope :openings, -> { where(kind: OPENING) }
  scope :appointments, -> { where(kind: APPOINTMENT) }
  scope :recurrent, -> (date) {
    where(weekly_recurring: true).
    where("starts_at < ?", date).
    where("strftime('%w', starts_at) = strftime('%w', ?)", date)
  }
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
      {
        date: date,
        slots: available_slots_for(date)
      }
    end
    
    def available_slots_for(date)
      openings_slots = openings_on(date).collect(&:slots).flatten
      appointments_slots = appointments_on(date).collect(&:slots).flatten
      openings_slots - appointments_slots
    end
  
    # Get openings on given day
    def openings_on(date)
      events = openings.starts_on(date).to_a
      events.present? ? events : recurrent_openings_for(date)
    end
  
    # Get reccurent openings for given day
    def recurrent_openings_for(date)
      recurrence_date = openings.recurrent(date).maximum(:starts_at)
      recurrence_date ? openings.starts_on(recurrence_date).to_a : []
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
  
  def appointment?
    kind == APPOINTMENT
  end
  
  def validate_opening_slot
    not_opened_slots = slots - self.class.available_slots_for(starts_at)
    errors[:base] << "Slots #{not_opened_slots.join(',')} are not open for appointment !" unless not_opened_slots.blank?
  end
  
end
