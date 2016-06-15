require_relative 'lib/oacis_watcher'

class MyWatcher < OacisWatcher

  def on_start
    puts "Hello OACIS Watcher !!!!"
  end

  def on_parameter_set_finished(ps)
    puts "ParameterSet #{ps.id} has finsihed !!!"
  end
end

watcher = MyWatcher.new( File.dirname(ENV['BUNDLE_GEMFILE']) )
watcher.observed_parameter_set_ids << "5649a7d36b696d6754000000"
watcher.run

