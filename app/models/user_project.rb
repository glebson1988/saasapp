# frozen_string_literal: true

class UserProject < ApplicationRecord
  belongs_to :project
  belongs_to :user
end
