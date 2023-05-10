I18n.module_eval do
  class << self
    # require service_name to any translatable query
    def translate_with_service_name(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}

      with_service_name = if !options.key?(:service_name)
                            service_name = translate_without_service_name(:service_name)
                            options.merge(service_name: service_name)
                          else
                            options
                          end

      translate_without_service_name(*(args << with_service_name))
    end

    alias_method :translate_without_service_name, :translate # Save the original :translate to :translate_without_service_name
    alias_method :translate, :translate_with_service_name    # Make :translate to point to :translate_with_service_name
  end
end
