require 'rails_helper'

describe EventsController do
  describe 'GET #index' do
    it 'has a 200 status code' do
      get :index
      expect(response.status).to eq(200)
    end

    it 'populates an array of events' do
      events = create_list(:event, 5)
      get :index
      expect(assigns(:events)).to eq(events)
    end

    it 'populates an array of websource' do
      events = create_list(:event, 5)
      websources = events.map(&:websource).uniq
      get :index
      expect(assigns(:websources)).to eq(websources)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET #show' do
    it 'has a 200 status code' do
      event = create(:event) 
      get :show, params: { id: event } 
      expect(response.status).to eq(200)
    end

    it 'assigns event' do
      event = create(:event) 
      get :show, params: { id: event } 
      expect(assigns(:event)).to eq(event)
    end

    it 'renders the show template' do
      event = create(:event) 
      get :show, params: { id: event } 
      expect(response).to render_template('show')
    end
  end
end
