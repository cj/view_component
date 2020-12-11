# frozen_string_literal: true

require "yaml"
require "pathname"

module ViewComponent
  module I18n
    # Expects a component to have a file with the same basename and
    # the .yml extension, holding translations scoped to the component's path.
    #
    # A component YML should look like this:
    #
    #   en:
    #     hello: "Hello World!"
    #
    # And inside the component will be possible to call
    #
    #   t(".hello") # => "Hello World!"
    #
    # Internally the scope will be expanded using the template's path.
    # As an example, the translation above from within `app/components/greeting/component.html.erb`
    # will result in an internal I18n key like this:
    #
    #   en:
    #     greeting:
    #       component:
    #         hello: "Hello World!"
    #
    #
    def self.load(components_root: "#{Rails.root}/app/components", glob: "**/*component.{yml,yaml}")
      Dir["#{components_root}/#{glob}"].each.with_object({}) do |path, translations|
        relative_path = Pathname(path).relative_path_from(Pathname(components_root)).to_s
        component_translations = YAML.load_file path
        scopes = relative_path.sub(/\.ya?ml/, "").split("/")

        component_translations.to_h.each do |locale, scoped_translations|
          translations[locale] ||= {}
          scopes.reduce(translations[locale]) do |nested_translations, scope|
            nested_translations[scope] ||= {}
          end
          translations[locale].dig(*scopes).merge! scoped_translations
        end
      end
    end
  end
end
