require 'slack-ruby-bot'
require 'sqlite3'
require 'pry'

Dir.glob('lib/**/*.rb').each{ |file| require_relative file }

class LunchBot < SlackRubyBot::Bot
  help do
    title 'Lunch Poll'
    desc 'Makes order Friday Lunch easier'

    command 'add' do
      desc 'Adds a new restaurant. Format: "<restaurant name>" "<link to menu>"'
    end

    command 'remove' do
      desc 'Removes an existing restaurant. Can be either the restaurant name or id'
    end

    command 'list' do
      desc 'Lists all the restaurants I know about'
    end

    command 'results' do
      desc 'Lists the current vote tallies'
    end

    command 'vote' do
      desc 'Add a vote for which restaurant you wish to go to. Can be either the restaurant name or id'
    end
  end

  restaurants_model = RestaurantsModel.new
  restaurants_view = RestaurantsView.new
  RestaurantsController.new(restaurants_model, restaurants_view)

  voting_model = VotingModel.new(restaurants_model)
  voting_view = VotingView.new(restaurants_model)
  VotingController.new(voting_model, voting_view)
end

LunchBot.run
