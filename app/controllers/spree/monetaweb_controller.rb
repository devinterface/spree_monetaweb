module Spree
  class MonetawebController < Spree::StoreController
    
    helper Spree::OrdersHelper

    def confirm
      @order = Order.find(params[:order_id])
      @payment_method = PaymentMethod.find params[:payment_method_id]
    end


    def buy
      if params[:payment_method_id] and PaymentMethod.exists? params[:payment_method_id]
        @payment_method = PaymentMethod.find params[:payment_method_id]
      else
        flash[:error] = "ERRORE, parametro payment_method_id errato, il metodo di pagamento con id=#{params[:payment_method_id]} non esiste !"
        redirect_to checkout_state_url(:payment)
      end
      @order = Order.find(params[:order_id])
      setefi_hosted_page_url = initialize_transaction()
      redirect_to setefi_hosted_page_url
    end


    def notify
      payment_id = params["paymentid"]
      payment_result = {
          paymentid: params["paymentid"],
          result: params["result"],
          authorizationcode: params["authorizationcode"],
          rrn: params["rrn"],
          merchantorderid: params["merchantorderid"],
          responsecode: params["responsecode"],
          threedsecure: params["threedsecure"],
          maskedPan: params["maskedpan"],
          cardcountry: params["cardcountry"],
          customfield: params["customfield"],
          securityToken: params["securitytoken"]
      }

      PAYMENT_RESULTS[payment_id] = payment_result
    end

    def recovery

    end


    private

    def initialize_transaction()
      require 'net/http'
      require 'rexml/document'

      @terminal_id = @payment_method.preferred_terminal_id
      @terminal_secret = @payment_method.preferred_terminal_secret

      setefi_payment_gateway_domain = 'https://test.monetaonline.it'
      transaction_init_path = '/monetaweb/payment/2/xml'
      init_uri = URI(setefi_payment_gateway_domain + transaction_init_path)


      # Setefi notifies the payment result to the merchant notify url
      # The merchant response, when the notify url is called, should contain the url where the card holder will be redirected to view the payment result (e.g. Payment Ok, Payment Failed)
      merchant_url_to_notify_payment_result = monetaweb_notify_url
      # If the notify url is not reachable, Setefi will redirect the card holder to the merchant recovery url
      merchant_recovery_url = monetaweb_recovery_url

      parameters = {
          id: @terminal_id, # Terminal Id
          password: @terminal_secret,
          operationType: 'initialize',
          amount: @order.total,
          currencyCode: '978', #EUR
          laguage: 'ITA',
          responseToMerchantUrl: merchant_url_to_notify_payment_result,
          recoveryUrl: merchant_recovery_url,
          merchantOrderId: @order.number,
          cardHolderName: 'Tom Smith',
          cardHolderEmail: 'tom.smith@test.com',
          description: 'Description',
          customField: 'Custom Field'
      }

      response = Net::HTTP.post_form(init_uri, parameters)
      raise "Payment initialization failed: #{response.body}" unless response.code == "200"

      xmlResponse = REXML::Document.new(response.body)
      payment_id = xmlResponse.root.elements["paymentid"].text
      hosted_page_url = xmlResponse.root.elements["hostedpageurl"].text

      "#{hosted_page_url}?PaymentID=#{payment_id}"
    end

  end
end