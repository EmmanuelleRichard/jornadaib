Jornadaib::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  #Rails4 config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  #config.action_view.debug_rjs             = true
  # Desativado para testes com cache de pagina - Rick config.action_controller.perform_caching = false
  #Desativado devido a problemas config.action_controller.perform_caching = true
  # config.cache_store = :file_store, "/public"
  config.cache_store = :dalli_store	#, 'lcalhost:11211', {:namespace => 'Speedflash'}
  #config.cache_store = :memory_store#, :size => 64.megabytes
  # config.action_controller.page_cache_directory = "/public/cache"

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true
  
	######### Assets Pipeline - Rick - Inicio ##########
	# Enable the asset pipeline
	config.assets.enabled = true

	# Live compilation
	config.assets.compile = true #false em production mode

	# Compress JavaScripts and CSS
	config.assets.compress = true

	# Expands the lines which load the assets
	config.assets.debug = true  #false em production mode
	# Generate digests for assets URLs
	config.assets.digest = false	#true em production mode


	# Serving static assets and setting cache headers 
	# which will be used by cloudfront as well
	# Disable Rails's static asset server (Apache or nginx will already do this)
	config.serve_static_files = true
	config.static_cache_control = "public, max-age=31536000"
	
	# config.assets.precompile += ['print.css']
	#config.assets.precompile += ['print.css', 'jquery-ui.min', 'jquery.ui.autocomplete.html.js']	
	# config.assets.precompile += %w( ckeditor/* )
	# config.assets.precompile += ['negociosite.css', 'ckeditor/init.js', 'ckeditor/ckeditor.js', 'ckeditor/filebrowser/javascripts/jquery.min.js', 'ckeditor/filebrowser/javascripts/jquery.tmpl.min.js', 'ckeditor/filebrowser/javascripts/fileuploader.js', 'ckeditor/filebrowser/javascripts/rails.js', 'ckeditor/filebrowser/javascripts/application.js']
	#20141102 config.assets.precompile += ['bootstrap.css', 'bootstrap-responsive.css', 'bootstrap-image-gallery.css', 'bootstrap-fileupload.min.css']
	#20141102 config.assets.precompile += ['jquery-ui.min', 'jquery.ui.autocomplete.html.js', 'jquery-ui-1.8.17/jquery.ui.core', 'jquery-ui-1.8.17/jquery.ui.datepicker', 'jquery-ui-1.8.17/jquery.ui.datepicker-pt-BR', 'jquery.dd.js']
	#20141102  config.assets.precompile += ['jquery.js', 'bootstrap.js', 'bootstrap-transition.js', 'bootstrap-alert.js', 'bootstrap-modal.js', 'bootstrap-dropdown.js', 'bootstrap-scrollspy.js', 'bootstrap-tab.js', 'bootstrap-tooltip.js', 'bootstrap-popover.js', 'bootstrap-button.js', 'bootstrap-collapse.js', 'bootstrap-carousel.js', 'bootstrap-typeahead.js', 'bootstrap-image-gallery.css', 'bootstrap-image-gallery.js', 'load-image.js', 'bootstrap-fileupload.min.js']
	#20141102 config.assets.precompile += ['negociosite.css', 'commons.css', 'skinshowimagem.css', 'ckeditor/init.js', 'ckeditor/ckeditor.js', 'ckeditor/filebrowser/javascripts/jquery.min.js', 'ckeditor/filebrowser/javascripts/jquery.tmpl.min.js', 'ckeditor/filebrowser/javascripts/fileuploader.js', 'ckeditor/filebrowser/javascripts/rails.js', 'ckeditor/filebrowser/javascripts/application.js']
	######### Assets Pipeline - Rick - Fim ##########
  
  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  #config.action_dispatch.best_standards_support = :builtin

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
=begin
	config.action_mailer.smtp_settings = {
		:enable_starttls_auto => false,
		:address => 'mail.onbit.com.br',
		:port => '25',
		:authentication => :login,
		:domain => 'onbit.com.br',
		:user_name => 'contato@onbit.com.br',
		:password => '123onbit'
	}  
=end	
	#rails4
	config.eager_load=false
end

