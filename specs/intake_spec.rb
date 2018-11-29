# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Intake Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    SecureMessage.setup(app.config)
    account_data = DATA[:accounts][1]
    @account = Waterious::EmailAccount.create(account_data)
    credentials = { username: account_data['username'],
                    password: account_data['password'] }
    signed_credentials = SecureMessage.sign(credentials)
    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/auth/authenticate/email_account', credentials.to_json, req_header
    result = JSON.parse(last_response.body)
    @auth_token = "Bearer #{result['auth_token']}"
    @req_header = { 'CONTENT_TYPE' => 'application/json',
                    'HTTP_AUTHORIZATION' => @auth_token }

    DATA[:summaries].each do |sum_data|
      Waterious::CreateSummaryForUser.call(
        owner_id: @account.id, summary_data: sum_data
      )
    end
  end

  describe 'Creating New Intake' do
    before do
      @sum = Waterious::Summary.first
      @int_data = DATA[:intakes][1]
    end

    it 'HAPPY: should be able to create new intake' do
      post "api/v1/summaries/#{@sum.id}/intake",
           @int_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']
      intake = Waterious::Intake.first

      _(created['id']).must_equal intake.id
      # _(created['call_url']).must_equal @req_data['call_url']
      # _(created['interval']).must_equal @req_data['interval']
    end
  end

  describe 'Lossing Some Hydration' do
    before do
      @sum = Waterious::Summary.first
      @int_data = DATA[:intakes][1]
    end

    it 'HAPPY: should be able to create loss some hydration' do
      get "api/v1/summaries/#{@sum.id}/loss", nil, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      loss = JSON.parse(last_response.body)['data']
      # puts loss.to_json
      # intake = Waterious::Intake.first

      # _(created['id']).must_equal intake.id
      # _(created['call_url']).must_equal @req_data['call_url']
      # _(created['interval']).must_equal @req_data['interval']
    end
  end
end
