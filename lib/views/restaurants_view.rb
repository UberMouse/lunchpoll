class RestaurantsView < SlackRubyBot::MVC::View::Base
  def add_response(added_restaurant, name, reason)
    if added_restaurant
      say("Succesfully added #{name}")
    else
      say("Failed to add #{name} because #{reason}")
    end
  end

  def remove_response(removed_restaurant, name)
    if removed_restaurant
      say("Successfully removed restaurant #{name}")
    else
      say("Failed to remove the restaurant (#{name}), I bet it didn't exist")
    end
  end

  def list_response(restaurants)
    message = restaurants.reduce("") { |message, restaurant| message << "#{restaurant.to_s}\r\n"}

    say("These are all the restaurants I know about")
    say(message)
  end

  private

  def say(message)
    client.say(channel: data.channel, text: message)
  end
end
