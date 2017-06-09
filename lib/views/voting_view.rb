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
    say("The results are")
    say(results.map do |name, count|
      "#{name}: #{count}"
    end.join("\r\n"))
  end

  def start_the_vote_response
    message = <<-MSG
    MSG

    say("The voting for Friday lunch has started, choose from one of the following restaurants and cast your vote")
    say(@restaurants.all.reduce("") { |msg, r| msg << "#{r}\r\n" })
  end

  def need_tie_breaker(tied_restaurants)
    say("The following restaurants are tied, a tie breaker will be needed: #{tied_restaurants.join(', ')}")
  end

  def tie_breaker_response(name)
    say("Broke the tie, #{name} is now the winner!")
  end

  def no_tie_breaker_needed
    say('The votes are not tied, no tie breaker needed')
  end

  def close_the_vote_response(winner, victim, voters)
    say("#{winner} has won! #{victim} you have been selected by the computer to perform the order")

    say("The following people voted")
    say(voters.join("\r\n"))
  end

  private

  def say(message)
    client.say(channel: data.channel, text: message)
  end
end
