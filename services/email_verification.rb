# frozen_string_literal: true

require 'http'

module Waterious
  # Error for invalid credentials
  class InvalidRegistration < StandardError; end

  # Find account and check password
  class EmailVerification
    SENDGRID_URL = 'https://api.sendgrid.com/v3/mail/send'

    def initialize(config)
      @config = config
    end

    def username_available?(registration)
      EmailAccount.first(username: registration[:username]).nil?
    end

    def email_body(registration)
      verification_url = registration[:verification_url]

      <<~END_EMAIL
        <p>Dear #{registration[:username]}, </p>
        <p>We received a request to create a new Waterious account for you. </br>
        To create a Waterious account, please <a href=\"#{verification_url}\">click here</a></p>
        <p>Best regards,</br>
        Waterious</p>
        </br>
        <hr>
        <p>Please do not reply to this email. </br>
        This email address is used only for sending email
        so you will not receive a response. 
      END_EMAIL
    end

    # rubocop:disable Metrics/MethodLength
    def send_email_verification(registration)
      HTTP.auth(
        "Bearer #{@config.SENDGRID_KEY}"
      ).post(
        SENDGRID_URL,
        json: {
          personalizations: [{
            to: [{ 'email' => registration[:email] }]
          }],
          from: { 'email' => 'noreply@Waterious.com' },
          subject: 'Waterious Registration Verification',
          content: [
            { type: 'text/html',
              value: email_body(registration) }
          ]
        }
      )
    rescue StandardError => error
      puts error.message
      raise(InvalidRegistration,
            'Could not send verification email; please check email address')
    end
    # rubocop:enable Metrics/MethodLength

    def call(registration)
      raise(InvalidRegistration, 'Username already exists') unless
        username_available?(registration)
        send_email_verification(registration)
    end
  end
end
