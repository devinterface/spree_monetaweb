class AddPaymentIdToPayments < ActiveRecord::Migration
  def change
    add_column :spree_payments, :monetaweb_payment_id, :string
  end
end
