#!/usr/bin/env ruby

require 'optparse'
require 'rubygems'
require 'aws-sdk'

options = {
  'region'  => 'us-west-2',
  'standby' => 'true'
}

parser = OptionParser.new do |opts|
  opts.banner = 'Usage: remove_asg_from_elb.rb -a ASG [-r REGION] [-x]'

  opts.on("-a", "--asg ASG", "Name of the ASG to remove (required)") do |opt|
    options['asg'] = opt
  end

  opts.on("-r", "--region REGION", "Name of the AWS region to use (default: #{options['region']})") do |opt|
    options['region'] = opt
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
auto_scaling.delete_auto_scaling_group(auto_scaling_group_name: options['asg'], force_delete: true)
