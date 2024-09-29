require 'rails_helper'

RSpec.describe Api::V1::ApplicationsController, type: :controller do
  # Define valid attributes for creating an application
  render_views false
  before do
    # API-only controllers do not need view paths, explicitly remove them
    controller.class.view_paths = []
  end
  let(:valid_attributes) { { name: 'Test Application' } }

  # Define invalid attributes for creating/updating an application
  let(:invalid_attributes) { { name: '' } }

  # Create a sample application before each test
  let!(:application) { create(:application) }

  # Test the create action
  describe 'POST /api/v1/create' do
    context 'with valid params' do
      it 'creates a new Application' do
        expect {
          post '/api/v1/create', params: { application: valid_attributes }
        }.to change(Application, :count).by(1)

        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body).to include('application_token', 'chats_count')
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity' do
        post :create, params: { application: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        response_body = JSON.parse(response.body)
        expect(response_body).to include('error')
      end
    end
  end
end
