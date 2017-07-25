require 'fluent-logger'

FLUENT = Fluent::Logger::FluentLogger.open(nil, :host=>'localhost', :port=>24224)

# FLUENT = Fluent::Logger::FluentLogger.new(nil, :host => 'localhost', :port => 24224, :nanosecond_precision => true
# log.post("myapp.access", {"agent" => "foo"})
# log.post_with_time("myapp.access", {"agent" => "foo"}, Time.now) # Need Time object for post_with_time