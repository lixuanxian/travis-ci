# http://michaelvanrooijen.com/articles/2011/06/01-more-concurrency-on-a-single-heroku-dyno-with-the-new-celadon-cedar-stack/

worker_processes 3 # amount of unicorn workers to spin up
timeout 30         # restarts workers that hang for 15 seconds

preload_app true

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
end

after_fork do |server, worker|
  require 'travis'

  Travis.config.update_periodically

  Travis::Amqp.connect

  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)

  if $metriks_reporter
    $metriks_reporter.stop
    $metriks_reporter.start
  end
end
