module Reviews
  module Cell
    module Form
      class ReviewAboutGuest < Trailblazer::Cell # :nodoc:
        include ActionView::Helpers::TranslationHelper
        alias_method :review, :model

        def only_read?
          @options[:only_read].present? ? @options[:only_read] : false
        end

      end
    end
  end
end
