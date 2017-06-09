class VotingView < SlackRubyBot::MVC::View::Base
  def added_vote_response(added_vote, failure_reason)
    if added_vote
      say('Successfully logged your vote')
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

  private

  def say(message)
    client.say(channel: data.channel, text: message)
  end
end
