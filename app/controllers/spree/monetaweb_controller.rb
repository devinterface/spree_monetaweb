module Spree
  class MonetawebController < Spree::StoreController
    skip_before_filter :verify_authenticity_token, :only => [:notify]
    before_filter :load_order
    before_filter :load_payment_method
    helper Spree::OrdersHelper

    def confirm
    end


    def buy
      unless @payment_method.present?
        flash[:error] = "ERRORE, parametro payment_method_id errato, il metodo di pagamento con id=#{params[:payment_method_id]} non esiste !"
        redirect_to checkout_state_url(:payment) and return
      end

      @payment = @order.payments.create!({:amount => @order.total,
                                          :payment_method => @payment_method
                                         })
      @payment.started_processing!

      setefi_hosted_page_url = initialize_transaction
      redirect_to setefi_hosted_page_url
    end


    def notify
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
      if payment_result[:result] == 'CAPTURED'
        @payment = @order.payments.where(:monetaweb_payment_id => payment_result[:paymentid]).first
        if @payment
          @payment.complete!
          @order.update_attributes({:state => "complete", :completed_at => Time.now}, :without_protection => true)
          @order.finalize!
        else
          @payment.failure!
        end
      end

      @url = "#{payment_result_url(payment_result)}"
      response.status = 200
      response.content_type = 'text/plain'
      response.body = @url
      render :layout => false
    end

    def recovery
    end

    def result
      if params[:result] == 'CAPTURED'
        #session[:order_id] = nil
        redirect_to checkout_state_url(:complete) # order_url(@order, {:checkout_complete => true, :order_token => @order.token}), :success => I18n.t("monetaweb.success")
      elsif params[:result] == 'CANCELED'
        flash[:error] = I18n.t('monetaweb.canceled')
        redirect_to checkout_state_url(:payment)
      end
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

      parameters = {
          id: @terminal_id,
          password: @terminal_secret,
          operationType: 'initialize',
          amount: @order.total,
          currencyCode: '978',
          laguage: 'ITA',
          responseToMerchantUrl: notify_payment_result_url,
          recoveryUrl: monetaweb_recovery_url(:order_id => @order.number, :payment_method_id => @payment_method.id),
          merchantOrderId: @order.number,
          cardHolderName: @order.billing_address.full_name,
          cardHolderEmail: @order.email,
          description: 'Description',
      }

      response = Net::HTTP.post_form(init_uri, parameters)
      raise "Payment initialization failed: #{response.body}" unless response.code == "200"

      xml_response = REXML::Document.new(response.body)
      payment_id = xml_response.root.elements["paymentid"].text
      @payment.update_column(:monetaweb_payment_id, payment_id)
      @payment.pend!
      hosted_page_url = xml_response.root.elements["hostedpageurl"].text

      "#{hosted_page_url}?PaymentID=#{payment_id}"
    end

    def load_order
      @order = Spree::Order.find_by!(number: params[:order_id])
    end

    def load_payment_method
      @payment_method = PaymentMethod.find params[:payment_method_id]
    end

    def notify_payment_result_url
      if Rails.env.development?
        "#{@payment_method.preferred_development_merchant_domain}/monetaweb/notify/#{@order.number}/#{@payment_method.id}"
      else
        monetaweb_notify_url(:order_id => @order.number, :payment_method_id => @payment_method.id)
      end
    end

    def payment_result_url(payment_result)
      if Rails.env.development?
        "#{@payment_method.preferred_development_merchant_domain}/monetaweb/result/#{@order.number}/#{@payment_method.id}/#{payment_result[:result]}"
      else
        monetaweb_result_url(:order_id => @order.number, :payment_method_id => @payment_method.id, :result => payment_result[:result])
      end
    end

  end
end