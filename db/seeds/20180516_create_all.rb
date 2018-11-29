# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, projects, requests, responses, token'
    create_accounts
    create_owned_projects
    create_requests
    create_responses
    create_tokens
    add_collaborators
    create_summaries
    create_intakes
    create_gones
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNERS_INFO = YAML.load_file("#{DIR}/owners_seed.yml")
PROJS_INFO = YAML.load_file("#{DIR}/projects_seed.yml")
COLLS_INFO = YAML.load_file("#{DIR}/collaborators_seed.yml")
REQUEST_INFO = YAML.load_file("#{DIR}/requests_seed.yml")
RESPONSE_INFO = YAML.load_file("#{DIR}/responses_seed.yml")
TOKEN_INFO = YAML.load_file("#{DIR}/tokens_seed.yml")

SUMMARIES_INFO = YAML.load_file("#{DIR}/summaries_seed.yml")
INTAKES_INFO = YAML.load_file("#{DIR}/intakes_seed.yml")
GONES_INFO = YAML.load_file("#{DIR}/gones_seed.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Waterious::EmailAccount.create(account_info)
  end
end

def create_owned_projects
  OWNERS_INFO.each do |owner|
    account = Waterious::Account.first(username: owner['username'])
    owner['proj_title'].each do |proj_title|
      proj_data = PROJS_INFO.find { |proj| proj['title'] == proj_title }
      Waterious::CreateProjectForOwner.call(
        owner_id: account.id, project_data: proj_data
      )
    end
  end
end

def create_requests
  req_info_each = REQUEST_INFO.each
  projects_cycle = Waterious::Project.all.cycle
  loop do
    req_info = req_info_each.next
    project = projects_cycle.next
    Waterious::CreateRequestForProject.call(
      project_id: project.id, request_data: req_info
    )
  end
end

def create_responses
  res_info_each = RESPONSE_INFO.each
  request_cycle = Waterious::Request.all.cycle
  loop do
    res_info = res_info_each.next
    request = request_cycle.next
    Waterious::CreateResponseForRequest.call(
      request_id: request.id, response_data: res_info
    )
  end
end

def create_tokens
  tok_info_each = TOKEN_INFO.each
  account_cycle = Waterious::Account.all.cycle
  loop do
    tok_info = tok_info_each.next
    account = account_cycle.next
    Waterious::CreateTokenForUser.call(
      owner_id: account.id, token_data: tok_info
    )
  end
end

def add_collaborators
  collaborators_info = COLLS_INFO
  collaborators_info.each do |collaborator|
    title = collaborator['project_title']
    emails = collaborator['collaborators_email']
    Waterious::AddCollaborators.call(
      project_title: title, collaborators_email: emails
    )
  end
end

def create_summaries
  sum_info_each = SUMMARIES_INFO.each
  account_cycle = Waterious::Account.all.cycle
  loop do
    sum_info = sum_info_each.next
    account = account_cycle.next
    Waterious::CreateSummaryForUser.call(
      owner_id: account.id, sum_info: sum_info
    )
  end
end

def create_intakes
  intakes_info_each = INTAKES_INFO.each
  summary_cycle = Waterious::Summary.all.cycle
  loop do
    intake_info = intakes_info_each.next
    summary = summary_cycle.next
    Waterious::CreateIntakeForSummary.call(
      summary_id: summary.id, intake_info: intake_info
    )
  end
end

def create_gones
  gones_info_each = GONES_INFO.each
  summary_cycle = Waterious::Summary.all.cycle
  loop do
    gone_info = gones_info_each.next
    summary = summary_cycle.next
    Waterious::CreateGoneForSummary.call(
      summary_id: summary.id, gone_info: gone_info
    )
  end
end
