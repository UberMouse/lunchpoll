class Vote
  attr_accessor :voter_name, :restaurant

  def initialize(voter_name, restaurant)
    @voter_name = voter_name
    @restaurant = restaurant
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

    before_count = row_count
    name = @restaurants.get_name(name_or_id)
    @db.execute('INSERT INTO votes (voter_id, restaurant_name) VALUES (?, ?)', data.user, name)

    [row_count > before_count, nil, name]
  end

  def results
    votes = []
    @db.execute("SELECT * FROM votes WHERE date = date('now', 'localtime')") do |row|
      users_name = client.users[row['voter_id']]["real_name"] rescue row['voter_id']
      votes << Vote.new(users_name, row['restaurant_name'])
    end

    grouped_votes = votes.group_by(&:restaurant)
    Hash[grouped_votes.map { |k, v| [k, v.length] }]
  end

  private

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
