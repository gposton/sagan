# sagan
Blue/Green deployments in AWS using Terraform

Carl Sagan originally proposed terraforming Venus to make it habitable
for human life.

This repo contains a set of scripts that can be used to trigger a
blue/green deployment in AWS using auto scaling groups and immutable
AMIs.

The process is as follows:

1. Remove the reference to the ASG and Launch config from terraform
   state file (terraform.tfstate)
1. Run terraform apply which will create a new ASG and launch
   configuration with the new AMI.
1. Verify functionality of the application.
1. Put the instances in the original ASG in 'Standby' mode so that it
   doesn't recieve new traffic.
1. Verify functionality of the application.
1. Delete the ASG (and associated instances) from AWS.

# How to

Given the terraform apply has been ran with the example template...

Set your AWS keys and install gem dependencies:

```
➜  sagan git:(master) ✗ export AWS_ACCESS_KEY_ID=<key>
➜  sagan git:(master) ✗ export AWS_SECRET_ACCESS_KEY=<secret>
➜  sagan git:(master) ✗ sudo gem install bundler
➜  sagan git:(master) ✗ bundle
```

Remove the reference to the ASG and Launch config from terraform state
file:

```
➜  sagan git:(master) ✗ ./remove_asg_from_tfstate.rb example_template/terraform.tfstate
Creating tfstate backup at example_template/terraform.tfstate.1430149712
Removed the following asg from example_template/terraform.tfstate:
web_ami-2593a715
```

Note the asg id above... you'll need this later (to take it out of service)

Run terraform apply to create the new ASG and launch config:

```
➜  sagan git:(master) ✗ cd example_template

➜  example_template git:(master) ✗ terraform apply
var.ami
  the AMI to use

  Enter a value: ami-c1a194f1

var.availability_zones
  A comma separated list of availability zones (no spaces)

  Enter a value:

var.count
  the number of instances to run

  Default: 3
  Enter a value:

var.instance_size
  EC2 instance size

  Default: t2.micro
  Enter a value:

var.key_name
  The name of the aws key used to launch instances

  Enter a value:

var.private_subnets
  A comma separated list of subnet ids (no spaces)

  Enter a value:

var.region
  the region we are gong to run in

  Enter a value:

var.vpc_id
  A vpc id

  Enter a value:

aws_security_group.web_server: Refreshing state... (ID: sg-fcccc799)
aws_elb.web_lb: Refreshing state... (ID: web-elb)
aws_launch_configuration.launch_config: Creating...
...
aws_launch_configuration.launch_config: Creation complete
aws_autoscaling_group.asg: Creating...
...
aws_autoscaling_group.asg: Creation complete

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate
```

Verify functionality of the application and then put the original ASG
in standby:

```
➜  example_template git:(master) ✗ cd ..

➜  sagan git:(master) ✗ ./put_asg_in_standby.rb -h
Usage: put_asg_in_standby.rb -a ASG [-r REGION] [-x]
    -a, --asg ASG                    Name of the ASG to remove (required)
    -r, --region REGION              Name of the AWS region to use (default: us-west-2)
    -x, --exit-standby               If set, remove the ASG from standby
    -h, --help                       Prints this help

➜  sagan git:(master) ✗ ./put_asg_in_standby.rb -a web_ami-2593a715
Putting the following instances on standby:
i-56e078a0
i-d8fcd211
i-17be76e0
```

Verify the functionality of the application then terminate the original
ASG (You will not be able to roll back after this step):

```
➜  sagan git:(master) ✗ ./terminate_asg.rb -h
Usage: remove_asg_from_elb.rb -a ASG [-r REGION] [-x]
    -a, --asg ASG                    Name of the ASG to remove (required)
    -r, --region REGION              Name of the AWS region to use (default: us-west-2)
    -h, --help                       Prints this help

➜  sagan git:(master) ✗ ./terminate_asg.rb -a web_ami-2593a715
```

# Rollback

To remove an ASG from standby and put it back in service run:

```
➜  sagan git:(master) ✗ ./put_asg_in_standby.rb -a web_ami-c1a194f1 -x
Removing the following instances from standby:
i-ade27a5b
i-e1fad428
i-09bf77fe
```

You can now put the new ASG in standby to debug it (or delete it for
a full rollback).
