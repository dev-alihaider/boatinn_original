# frozen_string_literal: true

json.boats @boats, partial: 'boat', as: :boat

json.prices do
  json.minimum in_current_currency(@min_price)
  json.maximum in_current_currency(@max_price)
end

json.pagination do
  json.total_pages  @boats.total_pages
  json.total_count  @boats.total_count
  json.current_page @boats.current_page
end
