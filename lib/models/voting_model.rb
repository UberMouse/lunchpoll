class Vote
  attr_accessor :voter_name, :restaurant

  def initialize(voter_name, restaurant)
    @voter_name = voter_name
    @restaurant = restaurant
  end
end

class RestaurantResult
  attr_accessor :name, :votes

  def initialize(name, votes)
    @name = name
    @votes = votes
  end
end

class VotingModel < SlackRubyBot::MVC::Model::Base
  def initialize(restaurants_model)
    @db = SQLite3::Database.new('lunch_bot.db')
    @db.results_as_hash = true
    @restaurants = restaurants_model

    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS votes (
        voter_id VARCHAR(255),
        restaurant_name VARCHAR(255),
        date DATE DEFAULT (date('now', 'localtime'))
      );
    SQL
  end

  def add_vote(name_or_id)
    return [false, 'that restaurant does not exist', nil] unless @restaurants.exists(name_or_id)
    return [false, 'you have already voted', nil] if vote_exists(data.user)

    name = @restaurants.get_name(name_or_id)
    [create_new_vote(name_or_id), nil, name]
  end

  def results
    votes = []
    @db.execute("SELECT * FROM votes WHERE date = date('now', 'localtime')") do |row|
      users_name = client.users[row['voter_id']]['real_name'] rescue row['voter_id']
      votes << Vote.new(users_name, row['restaurant_name'])
    end

    grouped_votes = votes.group_by(&:restaurant)
    Hash[grouped_votes.map { |k, v| [k, v.length] }]
  end

  def tied_restaurants
    most_votes = restaurant_with_highest_votes.votes
    duplicates = results.select { |_, votes| votes == most_votes }.map(&:first)

    return nil if duplicates.length == 1

    duplicates
  end

  def tied?
    tied_restaurants != nil
  end

  def tie_breaker(name_or_id)
    create_new_vote(name_or_id)

    @restaurants.get_name(name_or_id)
  end

  def random_voter_for_winning_restaurant
    winner = restaurant_with_highest_votes.name

    voters = get_voters(winner)

    voters.sample
  end

  def restaurant_with_highest_votes
    raw = results.sort_by { |_, votes| votes }.last

    RestaurantResult.new(raw.first, raw.last)
  end

  def all_voters
    voters = []
    @db.execute("SELECT voter_id FROM votes WHERE date = date('now', 'localtime')") do |row|
      voters << client.users[row['voter_id']]['real_name'] rescue row['voter_id']
    end

    voters
  end

  private

  def get_voters(name)
    voters = []
    @db.execute("SELECT voter_id FROM votes WHERE lower(restaurant_name) = ? AND date = date('now', 'localtime')", name.downcase)do |row|
      voters << client.users[row['voter_id']]['real_name'] rescue row['voter_id']
    end

    voters
  end

  def create_new_vote(name_or_id)
    before_count = row_count
    name = @restaurants.get_name(name_or_id)

    @db.execute('INSERT INTO votes (voter_id, restaurant_name) VALUES (?, ?)', data.user, name)

    row_count > before_count
  end

  def vote_exists(user_id)
    vote_exists = false
    @db.execute("SELECT * FROM votes WHERE voter_id = ? AND date = date('now', 'localtime')", user_id) do |row|
      vote_exists = row['voter_id'] == user_id
    end

    vote_exists
  end

  def row_count
    statement = @db.prepare 'SELECT COUNT(*) FROM votes'
    result = statement.execute
    result.next_hash['COUNT(*)']
  end
end
