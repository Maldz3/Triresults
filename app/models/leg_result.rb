class LegResult
  include Mongoid::Document
  field :secs, type: Float

  embedded_in :entrant
  embeds_one :event, as: :parent

  validates :event, presence: true

  def calc_ave

  end

  after_initialize do |doc|
    calc_ave
  end

  def secs=(value)
    self[:secs] = value
    calc_ave
  end

end

class SwimResult < LegResult
  field :pace_100, type: Float
  def calc_ave
    if event && secs
      meters = event.meters
      self.pace_100=meters.nil? ? nil : secs/(meters/100)
    end
  end
end

class BikeResult < LegResult
  field :mph, type: Float
  def calc_ave
    if event && secs
      miles = event.miles
      self.mph=miles.nil? ? nil : miles*3600/secs
    end
  end
end

class RunResult < LegResult
  field :mmile, type: Float, as: :minute_mile
  def calc_ave
    if event && secs
      miles = event.miles
      self.mmile=miles.nil? ? nil : (secs/60)/miles
    end
  end
end
