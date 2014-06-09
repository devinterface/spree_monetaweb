module Spree
  CheckoutController.class_eval do

    before_filter :redirect_for_monetaweb, :only => :update

    private

    def redirect_for_monetaweb
      return unless (params[:state] == "payment")
      return unless params[:order][:payments_attributes]

      payment_method = Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
      return unless payment_method.kind_of?(Spree::PaymentMethod::MonetaWeb)

      update_params = object_params.dup
      update_params.delete(:payments_attributes)
      load_order
      if @order.update_attributes(update_params)
        fire_event('spree.checkout.update')
      end

      if not @order.errors.empty?
         render :edit and return
      end

      redirect_to monetaweb_confirm_path(:order_id => @order.number, :payment_method_id => payment_method.id) and return
    end

  end
end