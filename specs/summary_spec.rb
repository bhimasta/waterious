# frozen_string_literal: true

require_relative '../lib/secure_message.rb'
require_relative 'spec_helper.rb'
require 'econfig'
require 'http'

describe 'Test Summary Handling' do
  extend Econfig::Shortcut
  Econfig.env = 'test'.to_s
  Econfig.root = '.'

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
  end

  it 'HAPPY: should be able to get list of all summaries' do
    DATA[:summaries].each do |summary_data|
      Waterious::CreateSummaryForUser.call(
        owner_id: @account.id, summary_data: summary_data
      )
    end

    get 'api/v1/summaries', nil, @req_header
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result.count).must_equal 3
  end

  it 'HAPPY: should be able to get details of today summary' do
    DATA[:summaries].each do |summary_data|
      summary_data['date_start'] = Date.today
      Waterious::CreateSummaryForUser.call(
        owner_id: @account.id, summary_data: summary_data
      )
    end

    get '/api/v1/summaries/today', nil, @req_header
    _(last_response.status).must_equal 200
  end
end
