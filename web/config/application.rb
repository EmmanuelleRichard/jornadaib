require File.expand_path('../boot', __FILE__)

require 'rails/all'

require 'RedCloth'

require 'brazilian-rails' 

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Jornadaib
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
	#config.autoload_paths += %W(#{config.root}/app/jobs)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = "Brasilia"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    # config.i18n.default_locale = 'pt-BR'
    # config.i18n.default_locale = "pt-BR"
	#config.i18n.load_path += Dir[Rails.root.join('devise', 'locales', '*.{rb,yml}').to_s]
	config.i18n.default_locale = :"pt-BR"
	I18n.locale = :"pt-BR"

	
    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"
    # config.encoding = "ISO-8859-1"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password] 
    
    #config.middleware.use Rack::SslEnforcer    
    # http://felipepavao.com/801/exception-notification-e-rails-3/
    # config.middleware.use ExceptionNotifier,
        # :email_prefix => "[S2Erros] ",
        # :sender_address => %{"Exception Notifier" <contato@onbit.com.br>},
        # :exception_recipients => %w{suporte@onbit.com.br},
        # :ignore_crawlers      => %w{Googlebot bingbot}
            
    # Enable the asset pipeline
    #config.assets.enabled = true
    #For faster asset precompiles, you can partially load your application by setting
    #config.assets.initialize_on_precompile = false
        
# config.assets.paths << "#{Rails.root}/app/assets/mobile"  #adicionado por rick para angularjs
# config.angular_templates.inside_paths   = [Rails.root.join('app', 'assets', 'mobile', 'www', 'views')]

    #rails4 abaixo
    # via https://github.com/sstephenson/sprockets/issues/347#issuecomment-25543201

    # We don't want the default of everything that isn't js or css, because it pulls too many things in
    config.assets.precompile.shift

    # Explicitly register the extensions we are interested in compiling
    config.assets.precompile.push(Proc.new do |path|
      File.extname(path).in? [
        '*.html',  '*/*.html',
        '.html', '.erb', '.haml',                 # Templates
        '.png',  '.gif', '.jpg', '.jpeg', '.svg', # Images
        '.eot',  '.otf', '.svc', '.woff', '.ttf', # Fonts
      ]
    end)    

    # config.middleware.insert_before 0, "Rack::Cors" do
    #   allow do
    #     origins '*'
    #     resource '*', :headers => :any, :methods => [:get, :put, :delete, :post, :options]
    #   end
    # end    

    # config.middleware.use Rack::Cors do
    #   allow do
    #     origins '*'
    #     resource '*',
    #       :headers => :any,
    #       :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
    #       :methods => [:get, :post, :options, :delete, :put]
    #   end
    # end    
    config.middleware.insert_before 0, "Rack::Cors" do #, :debug => true, :logger => (-> { Rails.logger }) do
      allow do
        origins '*'

        # resource '/cors',
        #   :headers => :any,
        #   :methods => [:post],
        #   :credentials => true,
        #   :max_age => 0

        resource '*',
          :headers => :any,
          :methods => [:get, :post, :delete, :put, :options, :head],
          :credentials => true,
          :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
          :max_age => 0
      end
    end

    #desabilitar o scaffold do InheritedResources
    config.app_generators.scaffold_controller = :scaffold_controller    
  end
end