#!/usr/bin/env bash
# Usage: scripts/stack.sh up|down|status
# Lab quirk: the lab role cannot call autoscaling:DeletePolicy, but deleting the ASG
# removes its policies. So on "down" we drop the policy from state before destroying.
set -euo pipefail
cd "$(dirname "$0")/../terraform"
export AWS_PAGER=""
: "${AWS_PROFILE:?export AWS_PROFILE=aca-lab first}"

set_flag() { sed -i '' "s/^stack_enabled.*/stack_enabled = $1/" lab.auto.tfvars; grep '^stack_enabled' lab.auto.tfvars; }

case "${1:-}" in
  up)
    set_flag true
    terraform apply -auto-approve
    echo ">>> Stack up. RDS is new and EMPTY: run the data import before testing the query page."
    ;;
  down)
    set_flag false
    if terraform state list | grep -q 'aws_autoscaling_policy.cpu_target\[0\]'; then
      terraform state rm 'aws_autoscaling_policy.cpu_target[0]'
    fi
    terraform apply -auto-approve
    ;;
  status)
    grep '^stack_enabled' lab.auto.tfvars
    aws ec2 describe-nat-gateways --filter Name=state,Values=available,pending --query 'length(NatGateways)' --output text | sed 's/^/NAT gateways: /'
    aws elbv2 describe-load-balancers --query 'length(LoadBalancers)' --output text | sed 's/^/Load balancers: /'
    aws rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier,DBInstanceStatus]' --output text | sed 's/^/RDS: /'
    aws ec2 describe-instances --filters Name=instance-state-name,Values=running,pending --query 'length(Reservations[].Instances[])' --output text | sed 's/^/Running EC2: /'
    ;;
  *) echo "usage: $0 up|down|status"; exit 2 ;;
esac
