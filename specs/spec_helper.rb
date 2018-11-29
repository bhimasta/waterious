# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  Waterious::Account.dataset.destroy
  Waterious::Project.dataset.destroy
  Waterious::Request.dataset.destroy
  Waterious::Response.dataset.destroy
  Waterious::Token.dataset.destroy
  Waterious::Summary.dataset.destroy
  Waterious::Intake.dataset.destroy
  Waterious::Gone.dataset.destroy
end

DATA = {}
DATA[:accounts] = YAML.safe_load File.read('db/seeds/accounts_seed.yml')
DATA[:projects] = YAML.safe_load File.read('db/seeds/projects_seed.yml')
DATA[:requests] = YAML.safe_load File.read('db/seeds/requests_seed.yml')
DATA[:responses] = YAML.safe_load File.read('db/seeds/responses_seed.yml')
DATA[:tokens] = YAML.safe_load File.read('db/seeds/tokens_seed.yml')

DATA[:summaries] = YAML.safe_load File.read('db/seeds/summaries_seed.yml')
DATA[:intakes] = YAML.safe_load File.read('db/seeds/intakes_seed.yml')
DATA[:gones] = YAML.safe_load File.read('db/seeds/gones_seed.yml')
