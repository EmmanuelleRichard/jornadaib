ActionMailer::Base.default_url_options[:host] = "www.jornadaib.com.br"

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.perform_deliveries = true

ActionMailer::Base.smtp_settings = {
  :address              => "192.168.0.10",
  :port                 => 25,
  :domain               => "jornadaib.com.br",
  :user_name            => "contato@jornadaib.com.br",
  :password             => "XXXXXXX",
  :authentication       => :login,
  :enable_starttls_auto => false
}
