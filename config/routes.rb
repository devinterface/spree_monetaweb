Spree::Core::Engine.routes.draw do
  get 'monetaweb/confirm/:order_id/:payment_method_id' => 'monetaweb#confirm', :as => :monetaweb_confirm
  post 'monetaweb/buy/:order_id/:payment_method_id' => 'monetaweb#buy', :as => :monetaweb_buy
  get 'monetaweb/recovery' => 'monetaweb#recovery', :as => :monetaweb_recovery
  get 'monetaweb/notify' => 'monetaweb#notify', :as => :monetaweb_notify
end
