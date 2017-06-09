class VotingController < SlackRubyBot::MVC::Controller::Base
  def vote
    added_vote, reason, name = model.add_vote(match[:expression])

    view.added_vote_response(added_vote, reason, name)
  end

  def results
    results = model.results

    view.results_response(results)
  end

  def start_the_vote
    view.start_the_vote_response
  end
end
