# frozen_string_literal: true

require 'json'
require 'sequel'

require_relative 'account/account'
module Waterious
  # Models a project
  class Project < Sequel::Model
    many_to_one :owner, class: :'Waterious::Account'

    many_to_many :collaborators,
                 class: :'Waterious::Account',
                 join_table: :accounts_projects,
                 left_key: :project_id, right_key: :collaborator_id

    one_to_many :requests
    plugin :association_dependencies, requests: :destroy

    plugin :timestamps
    plugin :whitelist_security

    set_allowed_columns :title, :description, :public_url, :owner_id

    def public_url
      SecureDB.decrypt(self.public_url_secure)
    end

    def public_url=(plaintext)
      self.public_url_secure = SecureDB.encrypt(plaintext)
    end

    def to_h
      {
        type: 'project',
        id: id,
        title: title,
        description: description,
        public_url: public_url
      }
    end

    def to_json(options = {})
      JSON(to_h, options)
    end

    def full_details
      to_h.merge(
        owner: owner,
        collaborators: collaborators,
        requests: Requests.new(requests)
      )
    end
  end
end
