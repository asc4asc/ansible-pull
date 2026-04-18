#!/usr/bin/env bash
set -euo pipefail
ansible-playbook -v testhost.yml -e target_hosts="localhost"
