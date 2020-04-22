# frozen_string_literal: true

class Tenant < ApplicationRecord
  acts_as_universal_and_determines_tenant
  has_many :members, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_one :payment
  accepts_nested_attributes_for :payment
  validates_uniqueness_of :name
  validates_presence_of :name

  def self.create_new_tenant(tenant_params, _user_params, coupon_params)
    tenant = Tenant.new(tenant_params)

    if new_signups_not_permitted?(coupon_params)
      raise ::Milia::Control::MaxTenantExceeded,
            'Sorry, new accounts not permitted at this time'
    else
      tenant.save
    end

    tenant
  end

  def self.new_signups_not_permitted?(_params)
    false
  end

  def self.tenant_signup(user, _tenant, _other = nil)
    Member.create_org_admin(user)
  end

  def can_create_projects?
    (plan == 'free' && projects.count < 1) || (plan == 'premium')
  end
end
