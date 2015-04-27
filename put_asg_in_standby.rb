#!/usr/bin/env ruby

require 'optparse'
require 'rubygems'
require 'aws-sdk'

options = {
  'region'  => 'us-west-2',
  'standby' => 'true'
}

parser = OptionParser.new do |opts|
  opts.banner = 'Usage: put_asg_in_standby.rb -a ASG [-r REGION] [-x]'

  opts.on("-a", "--asg ASG", "Name of the ASG to remove (required)") do |opt|
    options['asg'] = opt
  end

  opts.on("-r", "--region REGION", "Name of the AWS region to use (default: #{options['region']})") do |opt|
    options['region'] = opt
  end

  opts.on("-x", "--exit-standby", "If set, remove the ASG from standby") do
    options['standby'] = false
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end

# Parse options
parser.parse!

required_options = %w{asg}
required_options.each do |option|
  if options[option].nil?
    puts "Error required argument (#{option}) is missing."
    puts parser.help
    exit 1
  end
end

auto_scaling = Aws::AutoScaling::Client.new(region: options['region'])
instances = auto_scaling.describe_auto_scaling_groups(auto_scaling_group_names: [options['asg']]).auto_scaling_groups[0].instances
if options['standby']
  instance_ids = []
  instances.each do |instance|
    instance_ids << instance.instance_id if instance.lifecycle_state == 'InService'
  end
  auto_scaling.update_auto_scaling_group(auto_scaling_group_name: options['asg'], min_size: 0)
  puts "Putting the following instances on standby:"
  puts instance_ids
  auto_scaling.enter_standby(auto_scaling_group_name: options['asg'], should_decrement_desired_capacity: true, instance_ids: instance_ids)
else
  instance_ids = []
  instances.each do |instance|
    instance_ids << instance.instance_id if instance.lifecycle_state == 'Standby'
  end
  puts "Removing the following instances from standby:"
  puts instance_ids
  auto_scaling.exit_standby(auto_scaling_group_name: options['asg'], instance_ids: instance_ids)
  auto_scaling.update_auto_scaling_group(auto_scaling_group_name: options['asg'], min_size: instance_ids.length)
end
