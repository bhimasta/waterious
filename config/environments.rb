# frozen_string_literal: true

require 'roda'
require 'econfig'

module Waterious
  # Configuration for the API
  class Api < Roda
    plugin :environments

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    configure :development, :test do
      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./specs/test_load_all'
      end
    end

    configure :development, :test do
      ENV['DATABASE_URL'] = 'sqlite://' + config.DB_FILENAME
      ENV['TZ'] = 'Asia/Taipei'
    end

    configure :production do
      # Don't specify: Heroku has DATABASE_URL environment variable
      ENV['TZ'] = 'Asia/Taipei'
    end

    # For all runnable environments
    configure :development, :test, :production do
      require 'sequel'
      DB = Sequel.connect(ENV['DATABASE_URL'])

      def self.DB
        DB
      end

      # SecureDB.setup(config)
      SecureDB.setup(config.DB_KEY)
      AuthToken.setup(config.MSG_KEY)
    end
  end
end
