require 'slack-ruby-bot'

Dir.glob('lib/**/*.rb').each{ |file| require_relative file }

class LunchBot < SlackRubyBot::Bot
  restaurant_model = RestaurantsModel.new
  restaurant_view = RestaurantsView.new
  RestaurantsController.new(restaurant_model, restaurant_view)

end

LunchBot.run
