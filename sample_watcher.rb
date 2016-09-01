require_relative 'lib/oacis_watcher'

class MyWatcher < OacisWatcher

  def on_start
    puts "Hello OACIS Watcher !!!!"
    ps = ParameterSet.first
    observed_parameter_set_ids << ps.id.to_s
  end

  def on_parameter_set_finished(ps)
    puts "ParameterSet #{ps.id} has finsihed !!!"
  end
end

require 'optparse'
options = {store_yml: "store.yml", logger: $stderr}
OptionParser.new do |opt|
  opt.on("-s STORE_FILE", "path to yaml file for storing states") {|v| options[:store_yml] = v }
  opt.on("-l LOG_FILE",   "path to log file. If this option is not given, logs are printed to stderr") {|v| options[:logger] = v }
  opt.parse!(ARGV)
end

watcher = MyWatcher.new( File.dirname(ENV['BUNDLE_GEMFILE']), options[:store_yml], options[:logger] )
watcher.run

