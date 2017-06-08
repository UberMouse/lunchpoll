class RestaurantsController < SlackRubyBot::MVC::Controller::Base
  def add
   success, name, reason = model.add(match[:expression])

   view.add_response(success, name, reason)
  end

  def remove
    success, name = model.remove(match[:expression])

    view.remove_response(success, name)
  end

  def list
    result = model.all

    view.list_response(result)
  end
end
