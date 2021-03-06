module Spree
  class PaymentMethod::MonetaWeb < PaymentMethod

    preference :development_merchant_domain, :string
    preference :terminal_id, :string, :required
    preference :terminal_secret, :password, :required
    preference :auto_capture, :boolean

    def actions
      %w{capture void}
    end

    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      ['pending'].include?(payment.state)
    end

    # Indicates whether its possible to void the payment.
    def can_void?(payment)
      payment.state != 'void'
    end

    def capture(*args)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def void(*args)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def source_required?
      false
    end

    def credit(money, credit_card, response_code, options = {})
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end
  end

end