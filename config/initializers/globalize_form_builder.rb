# frozen_string_literal: true

module ActionView
  module Helpers
    # Add `#globalize_fields_for` which generates hidden inputs with translation
    # `id` and `locale` for updating associated translations.
    class FormBuilder
      # See: https://github.com/jeroenj/spree-simple_product_translations/blob/master/lib/batch_translation.rb
      # Modifications:
      #   options = args.extract_options!
      #   form_object = @object || @object_name.to_s.camelize.constantize.new
      #   object = form_object.translations.select { |t| t.locale.to_s == locale.to_s }.first
      #   @template.fields_for(object_name, object, options, &proc)
      def globalize_fields_for(locale, *args, &proc)
        raise ArgumentError, 'Missing block' unless block_given?
        object_name = "#{@object_name}[translations_attributes][#{locale}]"
        object = @object.translations.select { |t| t.locale.to_s == locale.to_s }.first
        @template.concat @template.hidden_field_tag("#{object_name}[id]", object ? object.id : '')
        @template.concat @template.hidden_field_tag("#{object_name}[locale]", locale)
        @template.fields_for(object_name, object, *args, &proc)
      end
    end
  end
end

