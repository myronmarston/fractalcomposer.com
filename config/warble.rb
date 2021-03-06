# Warbler web application assembly configuration file
Warbler::Config.new do |config|
  # Temporary directory where the application is staged
  # config.staging_dir = "tmp/war"

  # Application directories to be included in the webapp.
  config.dirs = %w(app config db lib log script vendor tmp)

  # Additional files/directories to include, above those in config.dirs
  # config.includes = FileList["db"]
  config.includes = FileList["sun-web.xml", "Rakefile"] 
  
  # Additional files/directories to exclude
  # excluded because the production server has its own user_generated_files directory
  # that we don't want to stomp when we deploy.
  config.excludes = FileList["public/user_generated_files"]

  # Additional Java .jar files to include.  Note that if .jar files are placed
  # in lib (and not otherwise excluded) then they need not be mentioned here.
  # JRuby and JRuby-Rack are pre-loaded in this list.  Be sure to include your
  # own versions if you directly set the value
  # config.java_libs += FileList["lib/java/*.jar"]

  # Loose Java classes and miscellaneous files to be placed in WEB-INF/classes.
  # config.java_classes = FileList["target/classes/**.*"]

  # One or more pathmaps defining how the java classes should be copied into
  # WEB-INF/classes. The example pathmap below accompanies the java_classes
  # configuration above. See http://rake.rubyforge.org/classes/String.html#M000017
  # for details of how to specify a pathmap.
  # config.pathmaps.java_classes << "%{target/classes/,}p"

  # Gems to be included. You need to tell Warbler which gems your application needs
  # so that they can be packaged in the war file.
  # The Rails gems are included by default unless the vendor/rails directory is present.
  # config.gems += ["activerecord-jdbcmysql-adapter", "jruby-openssl"]
  # config.gems << "tzinfo"
  config.gems = ["activerecord-jdbc-adapter", "ActiveRecord-JDBC", "dr_nic_magic_models", "jruby-openssl", "mislav-will_paginate"]
  # Uncomment this if you don't want to package rails gem.
  # config.gems -= ["rails"]

  # The most recent versions of gems are used.
  # You can specify versions of gems by using a hash assignment:
  # config.gems["rails"] = "2.0.2"

  # Include gem dependencies not mentioned specifically
  config.gem_dependencies = true

  # Files to be included in the root of the webapp.  Note that files in public
  # will have the leading 'public/' part of the path stripped during staging.
  # config.public_html = FileList["public/**/*", "doc/**/*"]
  
  # user generated files get served out of symlinked directory on the server.
  # if you want to test in tomcat on your development machine, comment this out.
  config.public_html.exclude(/user_generated_files/)  

  # Pathmaps for controlling how public HTML files are copied into the .war
  # config.pathmaps.public_html = ["%{public/,}p"]

  # Name of the war file (without the .war) -- defaults to the basename
  # of RAILS_ROOT
  config.war_name = "ROOT"

  # Value of RAILS_ENV for the webapp
  config.webxml.rails.env = 'production'
  
  # Application booter to use, one of :rack, :rails, or :merb. (Default :rails)
  # config.webxml.booter = :rails

  # When using the :rack booter, "Rackup" script to use.
  # The script is evaluated in a Rack::Builder to load the application.
  # Examples:
  # config.webxml.rackup = %{require './lib/demo'; run Rack::Adapter::Camping.new(Demo)}
  # config.webxml.rackup = require 'cgi' && CGI::escapeHTML(File.read("config.ru"))

  # Control the pool of Rails runtimes. Leaving unspecified means
  # the pool will grow as needed to service requests. It is recommended
  # that you fix these values when running a production server!
  config.webxml.jruby.min.runtimes = 2
  config.webxml.jruby.max.runtimes = 4

  # JNDI data source name
  # config.webxml.jndi = 'jdbc/rails'
  config.webxml.jruby.session_store = 'db'
end