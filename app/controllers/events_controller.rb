class EventsController < ApplicationController

  def index
    if allowed_params.present?
      @events     = Event.search(allowed_params['search'],
                                 allowed_params['websource'],
                                 allowed_params['from_date'],
                                 allowed_params['to_date'] )
      @websources = Event.all.map(&:websource).uniq
    else
      @events     = Event.all
      @websources = @events.map(&:websource).uniq
    end
  end

  def show
    @event = Event.find(allowed_params[:id])
  end

  private

  def allowed_params
    params.permit(:id, :search, :websource, :from_date, :to_date)
  end
end
