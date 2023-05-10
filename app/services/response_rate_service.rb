# frozen_string_literal: true

module ResponseRateService
  module_function

  # return hash { avg_rate:, avg_seconds:, conversations:, answered: }
  def calculate_for(user)
    number_of_conversations = 0
    number_of_answers = 0
    number_of_seconds = 0

    Travel::Trip.where(seller_id: user.id).find_each do |trip|
      number_of_conversations += 1
      message = trip.messages.where(sender_id: user.id).first
      if message.present?
        number_of_answers += 1
        number_of_seconds += message.created_at.to_i - trip.created_at.to_i
      end
    end

    one_rate_percent = number_of_conversations.percent_of(1, :float)
    {
      avg_rate: number_of_answers.positive? ? (number_of_answers.to_f / one_rate_percent ) : 1,
      avg_seconds: number_of_seconds.positive? ? (number_of_seconds / number_of_answers).to_i : 0,
      conversations: number_of_conversations,
      answered: number_of_answers
    }
  end

  def reset_user(user)
    rate = calculate_for(user)
    user.update(
      avg_response_rate: rate[:avg_rate],
      avg_response_seconds: rate[:avg_seconds]
    )
  end
end
