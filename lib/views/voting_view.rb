class VotingView < SlackRubyBot::MVC::View::Base
  def initialize(restaurants_model)
    @restaurants = restaurants_model
  end

  def added_vote_response(added_vote, failure_reason, name)
    if added_vote
      say("Successfully logged your vote for #{name}")
    else
      say("Did not add your vote because #{failure_reason}")
    end
  end

  def results_response(results)
    results_table = results.map do |name, count|
      "#{name}: #{count}"
    end.join("\r\n")
    msg = <<-MSG
      The results are
      #{results_table}
    MSG

    say(msg)
  end

  def start_the_vote_response
    message = <<-MSG
    MSG

    say("The voting for Friday lunch has started, choose from one of the following restaurants and cast your vote")
    say(@restaurants.all.reduce("") { |msg, r| msg << "#{r}\r\n" })
  end

  private

  def say(message)
    client.say(channel: data.channel, text: message)
  end
end
