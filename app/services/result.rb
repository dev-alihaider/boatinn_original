# frozen_string_literal: true

module Result
  Success = Struct.new(
      :success, # Boolean
      :data, # Additional response data
  ) do

    def initialize(data = nil)
      self.success = true
      self.data = data
    end

    def failure?
      false
    end

    def success?
      true
    end

    def payload
      self.data
    end
  end

  Error = Struct.new(
      :success,
      :error_code,
      :error_msg,
      :data
  ) do
    def initialize(error_code_or_msg, data = nil)
      self.success = false
      if error_code_or_msg.class == Symbol
        self.error_code = error_code_or_msg
      else
        self.error_msg = error_code_or_msg
      end
      self.data = data
    end

    def failure?
      true
    end

    def success?
      false
    end

    def payload
      self.data
    end
  end
end
