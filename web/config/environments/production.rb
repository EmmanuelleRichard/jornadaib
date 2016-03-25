Jornadaib::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'  #necessario para exibir imagem do simple_captcha

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug
  config.log_level = :warn

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

	######### Assets Pipeline - Rick - Inicio ##########
	# Enable the asset pipeline
	config.assets.enabled = true

	# Live compilation
	config.assets.compile = true	#true em development

	# Compress JavaScripts and CSS
	config.assets.compress = true	#false em development

	# Expands the lines which load the assets
	config.assets.debug = false  #true em development
	# Generate digests for assets URLs
	config.assets.digest = true	#false em development


	# Serving static assets and setting cache headers 
	# which will be used by cloudfront as well
	# Disable Rails's static asset server (Apache or nginx will already do this)
	config.serve_static_files = true
	config.static_cache_control = "public, max-age=31536000"
	
	# config.assets.precompile += ['print.css', 'applicationempresa.css', 'applicationempresa.js', 's2perfis/expert.css', 's2perfis/comercio.css', 's2perfis/digitalbeauty.css']
	#config.assets.precompile += ['print.css', 'jquery-ui.min', 'jquery.ui.autocomplete.html.js']
	# config.assets.precompile += Ckeditor.assets
#	config.assets.precompile += ['modernizr-2.6.2.min.js', 'negociosite.css', 'commons.css', 'skinshowimagem.css', 'ckeditor/init.js', 'ckeditor/ckeditor.js', 'ckeditor/filebrowser/javascripts/jquery.min.js', 'ckeditor/filebrowser/javascripts/jquery.tmpl.min.js', 'ckeditor/filebrowser/javascripts/fileuploader.js', 'ckeditor/filebrowser/javascripts/rails.js', 'ckeditor/filebrowser/javascripts/application.js']
	# config.assets.precompile += ['bootstrap.css', 'bootstrap-responsive.css', 'bootstrap-image-gallery.css', 'bootstrap-fileupload.min.css']
	# config.assets.precompile += ['jquery-ui.min', 'jquery.ui.autocomplete.html.js', 'jquery-ui-1.8.17/jquery.ui.core', 'jquery-ui-1.8.17/jquery.ui.datepicker', 'jquery-ui-1.8.17/jquery.ui.datepicker-pt-BR', 'jquery.dd.js']
	# #config.assets.precompile += ['jquery.js', 'bootstrap.js', 'bootstrap-transition.js', 'bootstrap-alert.js', 'bootstrap-modal.js', 'bootstrap-dropdown.js', 'bootstrap-scrollspy.js', 'bootstrap-tab.js', 'bootstrap-tooltip.js', 'bootstrap-popover.js', 'bootstrap-button.js', 'bootstrap-collapse.js', 'bootstrap-carousel.js', 'bootstrap-typeahead.js', 'bootstrap-image-gallery.css', 'bootstrap-image-gallery.js', 'load-image.js', 'bootstrap-fileupload.min.js']
	# config.assets.precompile += ['bootstrap.js', 'bootstrap-transition.js', 'bootstrap-alert.js', 'bootstrap-modal.js', 'bootstrap-dropdown.js', 'bootstrap-scrollspy.js', 'bootstrap-tab.js', 'bootstrap-tooltip.js', 'bootstrap-popover.js', 'bootstrap-button.js', 'bootstrap-collapse.js', 'bootstrap-carousel.js', 'bootstrap-typeahead.js', 'bootstrap-image-gallery.css', 'bootstrap-image-gallery.js', 'load-image.js', 'bootstrap-fileupload.min.js']
	# config.assets.precompile += ['negociosite.css', 'commons.css', 'skinshowimagem.css', 'ckeditor/init.js', 'ckeditor/ckeditor.js', 'ckeditor/filebrowser/javascripts/jquery.min.js', 'ckeditor/filebrowser/javascripts/jquery.tmpl.min.js', 'ckeditor/filebrowser/javascripts/fileuploader.js', 'ckeditor/filebrowser/javascripts/rails.js', 'ckeditor/filebrowser/javascripts/application.js']

  config.assets.initialize_on_precompile = false  #false  
	######### Assets Pipeline - Rick - Fim ##########
  
  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
=begin
#rails4
	config.action_mailer.default_url_options = { :host => 'localhost:3000' }
	config.action_mailer.delivery_method = :smtp
	config.action_mailer.raise_delivery_errors = true
	config.action_mailer.perform_deliveries = true	
	config.action_mailer.smtp_settings = {
  :address              => "smtp.live.com",
  :port                 => 587,
  #:domain               => 'onbit.com.br',
  :domain               => 'live.com',
  :user_name            => 'jornadaib@onbit.com.br',
  :password             => '312tibno!',
  #:authentication       => 'plain',
  :authentication       => :login,
#  :ssl                  => true,
#  :tls                  => true,
  :enable_starttls_auto => true  }

=end
	# http://felipepavao.com/801/exception-notification-e-rails-3/
   config.middleware.use ExceptionNotification::Rack,
    :email => {
       :email_prefix => "[JIErros] ",
       :sender_address => %{"Exception Notifier" <contato@jornadaib.com.br>},
       :exception_recipients => %w{suporte@onbit.com.br},
       :ignore_crawlers      => %w{Googlebot bingbot}
     }
  #rails4
  config.eager_load=true       
end
