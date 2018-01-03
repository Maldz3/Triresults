class Point
  attr_accessor :longitude, :latitude

  def initialize(longitude, latitude)
    @longitude = longitude
    @latitude = latitude
  end

  def mongoize
    {:type=> 'Point', :coordinates=> [@longitude, @latitude]}
  end

  def self.demongoize(hash)
    return nil if hash.nil?
    long = hash[:coordinates][0]
    lat = hash[:coordinates][1]
    Point.new(long, lat)
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
