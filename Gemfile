source 'https://rubygems.org'
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end
# source 'https://gems.ruby-china.org'

gem 'rails', '>= 5.0.0.rc2', '< 5.1'
gem 'puma'
gem 'jbuilder', '~> 2.5'
gem 'rake'

# Assets
gem 'sass-rails', github: 'rails/sass-rails'
gem 'jquery-rails'
gem 'non-stupid-digest-assets'
gem 'turbolinks'

# Login & Authority
gem 'devise', git: 'https://github.com/plataformatec/devise.git'
gem 'cancancan'

# Store
gem 'mysql2'

#Third Part
gem 'meta-tags'
gem 'simple_form'
gem 'remotipart', '~> 1.2'
gem 'sitemap_generator'
gem 'spreadsheet'
gem 'roo'
gem 'whenever', :require => false
gem 'kaminari', github: 'amatsuda/kaminari'
gem 'default_where', github: 'qinmingyuan/default_where'
gem 'roo-xls', github: 'roo-rb/roo-xls'
gem 'cocoon'
gem 'savon'
gem 'seventeen_mon'

# Engines
gem 'rails_com', github: 'qinmingyuan/rails_com', tag: 'v0.7.3' 
gem 'default_form', github: 'qinmingyuan/default_form', tag: 'v2.4'

gem 'fluent-logger'

gem 'exifr'


group :development, :test do
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'pry-rails'
  gem 'database_cleaner'
  gem 'byebug', platform: :mri
  gem 'pry-byebug'
  gem 'ruby-progressbar'
  gem 'awesome_print'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console'
  gem 'mina', '1.0.6'
  gem 'mina-whenever'
end
