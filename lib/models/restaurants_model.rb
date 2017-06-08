class Restaurant
  attr_accessor :name, :menu

  def initialize(name, menu)
    @name = name
    @menu = menu
  end

  def to_s
    "#{name} (#{menu})"
  end
end

class RestaurantsModel < SlackRubyBot::MVC::Model::Base
  def initialize
    @models = []
  end

  def add(cmd_arguments)
    match = cmd_arguments.match(/"(.*)".+"(.*)"/)
    return [false, 'unknown', 'command formatted incorrectly'] if match == nil

    name, menu = match.captures

    @models << Restaurant.new(name, menu)

    [true, name, nil]
  end

  def remove(name)
    restaurant_exists = @models.any?{ |r| r.name == name }
    return [false, name] unless restaurant_exists

    @models = @models.select{ |r| r.name != name }

    [true, name]
  end

  def all
    @models
  end
end
