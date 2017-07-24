require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PreReport
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.active_record.default_timezone = :local
    config.time_zone = 'Beijing'
    config.i18n.default_locale = :zh
    config.autoload_paths += Dir["#{config.root}/lib"]
  end
end
