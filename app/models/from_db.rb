class FromDB < ActiveRecord::Base
  self.record_timestamps = false
  self.abstract_class = true
  DB_CONFIG = YAML.load_file(Rails.root.join('config', 'database.yml'))
  establish_connection(DB_CONFIG['from'])
end