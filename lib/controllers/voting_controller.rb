class VotingController < SlackRubyBot::MVC::Controller::Base
  def vote
    added_vote, reason = model.add_vote(match[:expression])

    view.added_vote_response(added_vote, reason)
  end

  def results
    results = model.results

    view.results_response(results)
  end
end
