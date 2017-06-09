class VotingController < SlackRubyBot::MVC::Controller::Base
  def vote
    added_vote, reason, name = model.add_vote(match[:expression])

    view.added_vote_response(added_vote, reason, name)
  end

  def results
    results = model.results

    view.results_response(results)
  end

  def tie_breaker
    name = model.tie_breaker(match[:expression])

    view.tie_breaker_response(name)

    close_the_vote
  end

  def start_the_vote
    view.start_the_vote_response
  end

  def close_the_vote
    if model.tied?
      tied_restaurants = model.tied_restaurants
      view.need_tie_breaker(tied_restaurants)

      return
    end

    random_voter = model.random_voter_for_winning_restaurant
    winner = model.restaurant_with_highest_votes.name
    voters = model.all_voters

    view.close_the_vote_response(winner, random_voter, voters)
  end
end
