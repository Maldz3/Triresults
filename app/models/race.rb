class Race
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  include Mongoid::Timestamps::Created

  field :n, type: String, as: :name
  field :date, type: Date
  field :loc, type: Address, as: :location
  field :next_bib, type: Integer, default: 0

  embeds_many :events, as: :parent, order: [:order.asc]
  has_many :entrants, foreign_key: "race._id", dependent: :delete, order: [:secs.asc, :bib.asc]

  scope :upcoming, ->{where(:date.gte=>Date.current)}
  scope :past, ->{where(:date.lt=>Date.current)}

  DEFAULT_EVENTS = {"swim"=>{:order=>0, :name=>"swim", :distance=>1.0, :units=>"miles"},
                    "t1"=> {:order=>1, :name=>"t1"},
                    "bike"=>{:order=>2, :name=>"bike", :distance=>25.0, :units=>"miles"},
                    "t2"=> {:order=>3, :name=>"t2"},
                    "run"=> {:order=>4, :name=>"run", :distance=>10.0, :units=>"kilometers"}}

  DEFAULT_EVENTS.keys.each do |name|
    define_method("#{name}") do
      event=events.select {|event| name==event.name}.first
      event||=events.build(DEFAULT_EVENTS["#{name}"])
    end
    ["order","distance","units"].each do |prop|
      if DEFAULT_EVENTS["#{name}"][prop.to_sym]
        define_method("#{name}_#{prop}") do
          event=self.send("#{name}").send("#{prop}")
        end
        define_method("#{name}_#{prop}=") do |value|
          event=self.send("#{name}").send("#{prop}=", value)
        end
      end
    end
  end

  def self.default
    Race.new do |race|
      DEFAULT_EVENTS.keys.each {|leg|race.send("#{leg}")}
    end
  end

  ["city", "state"].each do |action|
    define_method("#{action}") do
      self.location ? self.location.send("#{action}") : nil
    end
    define_method("#{action}=") do |name|
      object=self.location ||= Address.new
      object.send("#{action}=", name)
      self.location=object
    end
  end

  def next_bib
    self[:next_bib] += 1
  end

  def get_group(racer)
    if racer && racer.birth_year && racer.gender
      age = Date.current.year - 1 - racer.birth_year
      min_age = (age/10) * 10
      max_age = ((age/10 + 1) * 10) - 1
      if age > 59
        name = "masters #{racer.gender}"
      else
        name = "#{min_age} to #{max_age} (#{racer.gender})"
      end
      Placing.demongoize(:name=>name)
    end
  end

  def create_entrant(racer)
    e = Entrant.new
    e.build_race(attributes.symbolize_keys.slice(:_id, :n, :date))
    e.build_racer(racer.info.attributes)
    get_group(racer)
    self.events.map { |event| e.send("#{event.name}=", event) }
    if e.valid?
      e[:bib] = next_bib
      e.save!
      self.save!
    end
    e
  end

  def self.upcoming_available_to(racer)
    upcoming_race_ids = racer.races.pluck(:"race").map {|r| r[:_id]} #should use upcoming
    all_ids = self.upcoming.map{|r| r[:_id]}
    self.in(:id=>(all_ids - upcoming_race_ids))
  end

end
