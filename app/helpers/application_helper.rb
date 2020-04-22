# frozen_string_literal: true

module ApplicationHelper
  unless const_defined?(:ALERT_TYPES)
    ALERT_TYPES = %i[success info warning danger].freeze
  end

  def bootstrap_flash(options = {})
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?

      type = type.to_sym
      type = :success if type == :notice
      type = :danger if type == :alert
      type = :danger if type == :error
      next unless ALERT_TYPES.include?(type)

      tag_class = options.extract!(:class)[:class]
      tag_options = {
        class: "alert fade in alert-#{type} #{tag_class}"
      }.merge(options)

      close_button = content_tag(:button, raw('&times;'), type: 'button', class: 'close',
                                                          'data-dismiss' => 'alert')

      Array(message).each do |msg|
        text = content_tag(:div, close_button + msg, tag_options)
        flash_messages << text if msg
      end
    end
    flash_messages.join("\n").html_safe
  end

  def tenant_name(tenant_id)
    Tenant.find(tenant_id).name
  end

  def s3_link(_tenant_id, artifact_key)
    link_to artifact_key, artifact_key.to_s, class: 'main-link', target: 'new'
  end
end
