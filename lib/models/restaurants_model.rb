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
    @db = SQLite3::Database.new('lunch_bot.db')
    @db.results_as_hash = true

    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS restaurants (
        name VARCHAR(255),
        menu_link VARCHAR(2048)
      );
    SQL
  end

  def add(cmd_arguments)
    match = cmd_arguments.match(/"(.*)".+"(.*)"/)
    return [false, 'unknown', 'command formatted incorrectly'] if match == nil

    name, menu = match.captures

    @db.execute 'INSERT INTO restaurants VALUES (?, ?)', name, menu

    [true, name, nil]
  end

  def remove(name)
    return [false, name] unless exists(name)

    before_count = row_count
    @db.execute('DELETE FROM restaurants WHERE name = ?', name)

    [row_count < before_count, name]
  end

  def all
    models = []
    @db.execute('SELECT * FROM restaurants') do |row|
      p row
      models << Restaurant.new(row['name'], row['menu_link'])
    end

    models
  end

  def exists(name)
    restaurant_exists = false
    @db.execute('SELECT name FROM restaurants WHERE lower(name) = ?', name.downcase) do |row|
      restaurant_exists = row['name'] == name
    end

    restaurant_exists
  end

  private

  def row_count
    statement = @db.prepare 'SELECT COUNT(*) FROM restaurants'
    result = statement.execute
    result.next_hash['COUNT(*)']
  end
end
