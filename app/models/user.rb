# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable

  acts_as_universal_and_determines_account

  has_one :member, dependent: :destroy
  has_many :user_projects
  has_many :projects, through: :user_projects

  def is_admin?
    is_admin
  end
end
