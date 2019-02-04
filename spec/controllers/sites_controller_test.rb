require 'rails_helper'

describe SitesController do
  describe 'GET #new' do
    it 'has a 200 status code' do
      get :new
      expect(response.status).to eq(200)
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe 'POST #create' do
    it 'redirects to events path with valid attrs' do
      post :create, params: { site: attributes_for(:site) }
      expect(response).to redirect_to events_path
    end

    it 'renders new with invalid attrs' do
      post :create, params: { site: { url: '' } }
      expect(response).to render_template('new')
    end
  end
end
