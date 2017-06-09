class Restaurant
  attr_accessor :id, :name, :menu

  def initialize(id, name, menu)
    @id = id
    @name = name
    @menu = menu
  end

  def to_s
    "#{id}. #{name} (#{menu})"
  end
end

class RestaurantsModel < SlackRubyBot::MVC::Model::Base
  def initialize
    @db = SQLite3::Database.new('lunch_bot.db')
    @db.results_as_hash = true

    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS restaurants (
        id INTEGER PRIMARY KEY,
        name VARCHAR(255),
        menu_link VARCHAR(2048)
      );
    SQL
  end

  def add(cmd_arguments)
    match = cmd_arguments.match(/"(.*)".+"(.*)"/)
    return [false, 'unknown', 'the command was formatted incorrectly'] if match == nil

    name, menu = match.captures

    @db.execute 'INSERT INTO restaurants (name, menu_link) VALUES (?, ?)', name, menu

    [true, name, nil]
  end

  def remove(name_or_id)
    return [false, name_or_id] unless exists(name_or_id)

    column_name = number?(name_or_id) ? 'id' : 'lower(name)'
    before_count = row_count
    name = get_name(name_or_id)
    @db.execute("DELETE FROM restaurants WHERE #{column_name} = ?", name_or_id.downcase)

    [row_count < before_count, name]
  end

  def all
    models = []
    @db.execute('SELECT * FROM restaurants') do |row|
      models << Restaurant.new(row['id'], row['name'], row['menu_link'])
    end

    models
  end

  def exists(name)
    column_name = number?(name) ? 'id' : 'lower(name)'
    restaurant_exists = false
    @db.execute("SELECT name FROM restaurants WHERE #{column_name} = ?", name.downcase) do |row|
      restaurant_exists = true
    end

    restaurant_exists
  end

  def get_name(name_or_id)
    name = ''

    column_name = number?(name_or_id) ? 'id' : 'lower(name)'
    @db.execute("SELECT name FROM restaurants WHERE #{column_name} = ?", name_or_id.downcase) do |row|
      name = row['name']
    end

    name
  end

  private

  def row_count
    statement = @db.prepare 'SELECT COUNT(*) FROM restaurants'
    result = statement.execute
    result.next_hash['COUNT(*)']
  end

  def number?(str)
    str.to_i.to_s == str
  end
end
