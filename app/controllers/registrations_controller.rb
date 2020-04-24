# frozen_string_literal: true

class RegistrationsController < Milia::RegistrationsController
  skip_before_action :authenticate_tenant!, only: %i[new create cancel]

  def create
    tenant_params = sign_up_params_tenant
    user_params = sign_up_params_user.merge(is_admin: true)
    coupon_params = sign_up_params_coupon

    sign_out_session!
    prep_signup_view(tenant_params, user_params, coupon_params)

    if !::Milia.use_recaptcha || verify_recaptcha

      Tenant.transaction do
        @tenant = Tenant.create_new_tenant(tenant_params, user_params, coupon_params)
        if @tenant.errors.empty?
          if @tenant.plan == 'premium'
            @payment = Payment.new(email: user_params['email'],
                                   token: params[:payment]['token'],
                                   tenant: @tenant)
            unless @payment.valid?
              flash[:error] = 'Please check registration errors'
            end

            begin
              @payment.process_payment
              @payment.save
            rescue Exception => e
              flash[:error] = e.message
              @tenant.destroy
              log_action('Payment failed')
              render(:new) && return
            end
          end
        else
          resource.valid?
          log_action('tenant create failed', @tenant)
          render :new
        end

        if flash[:error].blank? || flash[:error].empty?
          initiate_tenant(@tenant)

          devise_create(user_params)

          if resource.errors.empty?

            log_action('signup user/tenant success', resource)
            Tenant.tenant_signup(resource, @tenant, coupon_params)

          else
            log_action('signup user create failed', resource)
            raise ActiveRecord::Rollback
          end
        else
          resource.valid?
          log_action('Payment processing failed', @tenant)
          render(:new) && return
        end
      end
    else
      flash[:error] = "Recaptcha codes didn't match; please try again"
      resource.valid?
      @tenant.valid?
      log_action('recaptcha failed', resource)
      render :new
    end
  end

  protected

  def sign_up_params_tenant
    params.require(:tenant).permit(::Milia.whitelist_tenant_params)
  end

  def sign_up_params_user
    devise_parameter_sanitizer.sanitize(:sign_up)
  end

  def sign_up_params_coupon
    (::Milia.use_coupon ?
         params.require(:coupon).permit(::Milia.whitelist_coupon_params) :
         params
    )
  end

  def sign_out_session!
    if user_signed_in?
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    end
  end

  def devise_create(user_params)
    build_resource(user_params)

    resource.skip_confirm_change_password = true if ::Milia.use_invite_member

    if resource.save
      yield resource if block_given?
      log_action('devise: signup user success', resource)
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        if is_flashing_format?
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
        end
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      log_action('devise: signup user failure', resource)
      prep_signup_view(@tenant, resource, params[:coupon])
      respond_with resource
    end
  end

  def after_sign_up_path_for(_resource)
    headers['refresh'] = "0;url=#{root_path}"
    root_path
  end

  def after_inactive_sign_up_path_for(_resource)
    headers['refresh'] = "0;url=#{root_path}"
    root_path
  end

  def log_action(action, resource = nil)
    err_msg = (resource.nil? ? '' : resource.errors.full_messages.uniq.join(', '))
    logger&.debug(
      "MILIA >>>>> [register user/org] #{action} - #{err_msg}"
    )
  end
end
