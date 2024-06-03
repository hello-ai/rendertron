#!/bin/bash

set -eo pipefail
gcloud compute instance-groups managed rolling-action restart rendertron-2-managed --zone asia-northeast1-b --max-unavailable 1 --quiet
