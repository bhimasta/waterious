# frozen_string_literal: true

require 'roda'

module Waterious
  # Web controller for Waterious API
  class Api < Roda
    route('auth') do |routing|
      routing.on 'forget_password' do
        # POST api/v1/auth/forget_password
        routing.post do
          recovery_data = JsonRequestBody.parse_symbolize(request.body.read)
          EmailAccount.first(email: recovery_data[:email])
          EmailRecovery.new(Api.config).call(recovery_data)
          response.status = 201
          { message: 'Verification email sent' }.to_json
        rescue NotRegistered => error
          routing.halt 400, { message: error.message }.to_json
        rescue StandardError => error
          puts "ERROR VERIFYING Email:  #{error.inspect}"
          puts error.message
          routing.halt 500
        end
      end

      routing.on 'authenticate' do
        # POST /auth/authenticate/github_account
        routing.post 'github_account' do
          auth_request = SignedRequest.new(Api.config)
                                      .parse(request.body.read)
          sso_account, auth_token =
            AuthenticateGithubAccount.new(Api.config)
                                     .call(auth_request[:access_token])
          # puts "sso: #{sso_account}"
          { account: sso_account, auth_token: auth_token }.to_json
        rescue StandardError => error
          puts "FAILED to validate Github account: #{error.inspect}"
          puts error.backtrace
          routing.halt 400
        end

        # POST /auth/authenticate/google_account
        routing.post 'google_account' do
          auth_request = SignedRequest.new(Api.config)
                                      .parse(request.body.read)
          # puts "auth_req: #{auth_request}"
          sso_account, auth_token =
            AuthenticateGoogleAccount.new(Api.config)
                                     .call(auth_request[:access_token])
          { account: sso_account, auth_token: auth_token }.to_json
        rescue StandardError => error
          puts "FAILED to validate Google account: #{error.inspect}"
          puts error.backtrace
          routing.halt 400
        end

        # POST /api/v1/auth/authenticate/email_account
        routing.post 'email_account' do
          credentials = JsonRequestBody.parse_symbolize(request.body.read)
          # credentials = SignedRequest.new(Api.config)
          #                            .parse(request.body.read)
          auth_account = AuthenticateEmailAccount.call(credentials)
          auth_account.to_json
        rescue StandardError => error
          puts "ERROR: #{error.class}: #{error.message}"
          routing.halt '403', { message: 'Invalid credentials' }.to_json
        end
        # routing.route('authenticate', 'auth')
      end
      routing.on 'register' do
        # POST api/v1/auth/register
        routing.post do
          registration = SignedRequest.new(Api.config)
                                      .parse(request.body.read)
          EmailVerification.new(Api.config).call(registration)

          response.status = 201
          { message: 'Verification email sent' }.to_json
        # rescue InvalidRegistration => error
        #   routing.halt 400, { message: error.message }.to_json
        rescue StandardError => error
          puts "ERROR VERIFYING REGISTRATION:  #{error.inspect}"
          puts error.message
          routing.halt 500
        end
      end
    end
  end
end
