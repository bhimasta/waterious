# frozen_string_literal: true

require 'json'
require 'sequel'

module Waterious
  # Models a secret request
  class Request < Sequel::Model
    many_to_one :project

    one_to_many :responses

    plugin :association_dependencies, responses: :destroy
    plugin :timestamps
    plugin :whitelist_security

    set_allowed_columns :project_id, :title, :description, :call_url,
                        :interval, :parameters, :date_start, :date_end, :next_request,
                        :json_path, :xml_path

    def parameters
      SecureDB.decrypt(parameters_secure)
    end

    def parameters=(plaintext)
      self.parameters_secure = SecureDB.encrypt(plaintext)
    end

    def to_h
      {
        type: 'request',
        id: id,
        title: title,
        description: description,
        call_url: call_url,
        interval: interval,
        parameters: parameters,
        date_start: date_start,
        date_end: date_end,
        next_request: next_request,
        json_path: json_path,
        xml_path: xml_path,
        created_at: created_at,
        updated_at: updated_at,
        project: project
      }
    end

    def to_json(options = {})
      JSON(to_h, options)
    end

    def full_details
      to_h.merge(
        responses: responses
      )
    end
  end
end
