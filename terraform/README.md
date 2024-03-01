# Terraform configs

This directory contains [Terraform](https://www.terraform.io/) configs for QURI infra.

Terraform state is managed through the remote S3 state, bootstrapped with configs in `./bootstrap` dir.

## How everything is organized

- `stacks/*` - Terraform "root modules" (each one has its own state file).
- `modules/*` - shared Terraform modules.
- `bootstrap` - bootstrapping Terraform configuration which sets up S3 bucket for all state files; it outputs state locally. We probably won't run it ever again.

Stacks are split by application ("guesstimate", "quri-hub", "metaforecast"). For shared resources, we can also create separate stacks, or a single stack for all shared resources.

## Picking state management solution

Previously tried for state management:

1. Local state - impossible to share with the team.
2. Terraform Cloud - slow, feature-incomplete, proprietary.
3. Spacelift with Spacelift-managed state - expensive for 3+ users, no Slack notifications on free plan, too many features that we don't need.

Also, all TACOS ("Terraform Automation and COllaboration Software") make the feedback loop from experimenting with Terraform too slow to be worth it.

## How to use

### Installing Terraform

You need to install:

1. Terraform; probably `brew install terraform` if you're on macOS.
   - If you're not on macOS, take care to install Terraform 1.5.7; that's the last open source version. We might migrate to [OpenTofu](https://opentofu.org/) in the future.
2. 1Password CLI; probably `brew install 1password-cli`.
3. Optionally, `brew install awscli` (see the next section).

### Configuring AWS credentials

To run Terraform, you need to access its state on AWS. So you need any AWS credentials with access to S3 and DynamoDB resources.

There are several possible solutions for this.

The easiest (and the least secure one), if you don't use AWS CLI for other needs, is to export `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment vars in your local shell that contain credentials for IAM root account. These can be obtained here: https://us-east-1.console.aws.amazon.com/iam/home?#/users/details/root/create-access-key

Alternatively, you could install AWS CLI (`brew install awscli`) and run `aws configure`, then enter the same key pair in its prompt. Then credentials would be saved in the `~/.aws/credentials` file, and Terraform will pick them from there.

In a more secure configuration, we'd create a separate AWS IAM user with permissions _only_ for S3 and DynamoDB resources, and then use those instead of root credentials. But we don't store anything sensitive on AWS yet, so it doesn't matter.

Another note: if you already use AWS CLI for another account, you can do `aws configure --profile quri-root` and then use `AWS_PROFILE=quri-root` whenever you run Terraform.

### Running

1. Go to `./terraform/stacks/[STACK]`.
2. Run `terraform plan`; you should see this message: "No changes. Your infrastructure matches the configuration."
3. Now you're free to edit the configuration, plan and apply it.
4. Don't forget to commit the configuration back to the repo when you're done.
