# frozen_string_literal: true

require "view_component/i18n"

ViewComponent::I18n.load components_root: "#{Rails.root}/app/components", glob: "**/*component.yml"
