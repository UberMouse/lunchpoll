require 'slack-ruby-bot'
require 'sqlite3'
require 'pry'

Dir.glob('lib/**/*.rb').each{ |file| require_relative file }

class LunchBot < SlackRubyBot::Bot
  restaurants_model = RestaurantsModel.new
  restaurants_view = RestaurantsView.new
  RestaurantsController.new(restaurants_model, restaurants_view)

  voting_model = VotingModel.new(restaurants_model)
  voting_view = VotingView.new(restaurants_model)
  VotingController.new(voting_model, voting_view)
end

LunchBot.run
