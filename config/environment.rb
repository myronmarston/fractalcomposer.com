# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

NEGATIVE_CAPTCHA_SECRET = '2c361596b4a1b6541d28a44ddeab3d7a6f1239664ff678363c32656b4c7e970de89cace1acdd88a7a226503b84ce865e5cdf5e6b6e552e7033e368531fc73e03' unless defined? NEGATIVE_CAPTCHA_SECRET

STATIC_PAGES = %w{about acknowledgements} unless defined? STATIC_PAGES

LICENSE_URL = 'http://creativecommons.org/licenses/by-sa/3.0/' unless defined? LICENSE_URL

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Inserted by NetBeans Ruby support to support JRuby
#if defined?(JRUBY_VERSION)
#  require 'rubygems'
#  gem 'activerecord-jdbc-adapter'
#  require 'jdbc_adapter'
#end

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_FractalComposerDotCom_session',
    :secret      => '564f8f40bcc8113309db93b20afdb3b8eaecf0a3d723f2a14d837efa93ce575f436b85e15519646c30af6df143a50e2e1adfc26e5906c30c80222f1421041621'
  }    

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # right now, I get an error from the active_record_store, see http://jira.codehaus.org/browse/JRUBY-2507
  config.action_controller.session_store = :active_record_store
  #config.action_controller.session_store = CGI::Session::PStore

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql
      
  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  config.action_controller.allow_forgery_protection = false    
  
  # required gems...
  #config.gem "RedCloth"
  #config.gem "activerecord-jdbc-adapter" 
end

ActiveRecord::Base.allow_concurrency = true

ExceptionNotifier.exception_recipients = %w(myron@fractalcomposer.com myron.marston@gmail.com)
ExceptionNotifier.sender_address = %("FractalComposer.com Exception Notifier" <exception.notifier@fractalcomposer.com>)
ExceptionNotifier.email_prefix = "[fractalcomposer Error] "

require 'will_paginate'
require 'dr_nic_magic_models'
require 'string_extensions'
require 'lib/atom_feed_helper'
require 'lib/slugalizer'