class Address
  attr_accessor :city, :state, :location

  def initialize(city=nil, state=nil, loc=nil)
    @city = city
    @state = state
    @location = loc
  end

  def mongoize
    {:city=> @city, :state=> @state, :loc=> Point.mongoize(@location)}
  end

  def self.demongoize(hash)
    return nil if hash.nil?
    city = hash[:city]
    state = hash[:state]
    location = Point.demongoize(hash[:loc])
    Address.new(city, state, location)
  end

  def self.mongoize(input)
    if input.is_a?(Hash)
      return input
    else
      return input.mongoize
    end
  end

  def self.evolve(input)
    self.mongoize(input)
  end

end
