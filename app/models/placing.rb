class Placing
  attr_accessor :name, :place

  def initialize(name, place)
    @name = name
    @place = place
  end

  def mongoize
    {:name=> @name, :place=> @place}
  end

  def self.demongoize(hash)
    return nil if hash.nil?
    name = hash[:name]
    place = hash[:place]
    Placing.new(name, place)
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
