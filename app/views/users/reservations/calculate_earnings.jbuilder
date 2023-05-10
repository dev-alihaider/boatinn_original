@totals.each do |key, sub_totals|
  json.set! key do
    sub_totals.each do |sub_key, sub_total|
      json.set!(sub_key, view_money(sub_total)) if sub_total.positive?
    end
  end
end

