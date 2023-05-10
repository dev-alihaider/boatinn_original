class BookingNewPresenter

  def wizard_step_items
    [
      {
        t_key: 'bookings.wizard.rule_link',
        url: '#rule'
      },
      {
        t_key: 'bookings.wizard.passengers_link',
        url: '#passengers'
      },
      {
        t_key: 'bookings.wizard.pay_link',
        url: '#pay'
      }
    ]
  end



end
