class EventsController < ApplicationController

  def index
    @events = Event.search(allowed_params[:search])
    @websources = @events.map(&:websource).uniq
  end

  private

  def allowed_params
    params.permit(:search, :url, :max_url, :interval)
  end
end
