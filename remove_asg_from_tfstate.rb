#!/usr/bin/env ruby

require 'optparse'
require 'rubygems'
require 'json'
require 'fileutils'

options = {
  'asg' => 'asg',
  'launch_config' => 'launch_config'
}

parser = OptionParser.new do |opts|
  opts.banner = 'Usage: remote_asg_from_tfstate.rb [-a ASG] [-l LAUNCH_CONFIG] PATH'

  opts.on("-a", "--asg", "Name of the asg to remove (default: #{options['asg']}") do |opt|
    options['asg'] = opt
  end

  opts.on("-l", "--launch-config", "Name of the launch configuration to remove (default: #{options['launch_config']}") do |opt|
    options['launch_config'] = opt
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end

# Parse options
parser.parse!

# Verify Account IDs have been provided
if ARGV.empty?
  puts "Error: Path to tfstate not found"
  puts parser.help
  exit 1
end

tf_state_path = ARGV.pop

tf_state = JSON.parse(File.read(tf_state_path))
asg_id = tf_state['modules'][0]['resources']["aws_autoscaling_group.#{options['asg']}"]['primary']['id']

tf_state['modules'][0]['resources'].reject!{ |k,v| k == "aws_autoscaling_group.#{options['asg']}" }
tf_state['modules'][0]['resources'].reject!{ |k,v| k == "aws_launch_configuration.#{options['launch_config']}" }

backup_file = "#{tf_state_path}.#{Time.now.to_i}"
puts "Creating tfstate backup at #{backup_file}"
FileUtils.mv(tf_state_path, backup_file)

File.write(tf_state_path, JSON.pretty_generate(tf_state))

puts "Removed the following asg from #{tf_state_path}:"
puts asg_id
