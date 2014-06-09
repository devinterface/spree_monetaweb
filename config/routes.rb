Spree::Core::Engine.routes.draw do
  get 'monetaweb/confirm/:order_id/:payment_method_id' => 'monetaweb#confirm', :as => :monetaweb_confirm
  post 'monetaweb/buy/:order_id/:payment_method_id' => 'monetaweb#buy', :as => :monetaweb_buy
  get 'monetaweb/recovery/:order_id/:payment_method_id/:payment_identifier' => 'monetaweb#recovery', :as => :monetaweb_recovery
  post 'monetaweb/notify/:order_id/:payment_method_id/:payment_identifier' => 'monetaweb#notify', :as => :monetaweb_notify
  get 'monetaweb/result/:order_id/:payment_method_id/:payment_identifier/:result' => 'monetaweb#result', :as => :monetaweb_result
end
