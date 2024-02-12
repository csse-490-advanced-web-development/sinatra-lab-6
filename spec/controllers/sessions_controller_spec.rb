require_relative "../spec_helper"

describe SessionsController do
  describe 'GET /sessions/current_user' do
    before do
      direct_login_as(Fabricate(:user, email: 'samantha@example.com'))
      get '/sessions/current_user'
    end

    it { expect(last_response.ok?) }
    it { expect(JSON.parse(last_response.body)).to eq({"email" => 'samantha@example.com'}) }
  end
end
