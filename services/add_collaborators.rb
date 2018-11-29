# frozen_string_literal: true

module Waterious
  # Service object to add collaborators
  class AddCollaborators
    def self.call(project_title:, collaborators_email:)
      proj = Waterious::Project.first(title: project_title)
      collaborators_email.each do |email|
        collaborator = Waterious::Account.first(email: email)
        proj.add_collaborator(collaborator)
      end
    end
  end
end
