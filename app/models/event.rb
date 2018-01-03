class Event
  include Mongoid::Document
  field :o, type: Integer, as: :order
  field :n, type: String, as: :name
  field :d, type: Float, as: :distance
  field :u, type: String, as: :units

  validates :order, :name, presence: true

  embedded_in :parent, polymorphic: true, touch: true

  def meters
    return nil if d.nil? || u.nil?
    case u
    when 'meters'
      d * 1.0
    when 'miles'
      d * 1609.344
    when 'yards'
      d * 0.9144
    when 'kilometers'
      d * 1000
    end
  end

  def miles
    return nil if d.nil? || u.nil?
    case u
    when 'meters'
      d * 0.000621371
    when 'miles'
      d * 1.0
    when 'yards'
      d * 0.000568182
    when 'kilometers'
      d * 0.621371
    end
  end
end
