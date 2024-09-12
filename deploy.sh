#!/bin/bash
read -p "Hash to deploy: " hash
read -p "dev/prod: " env

KUBECONFIG=~/.kube/datahub-${env}.yml kubectl set image deployment/ckan-${env} ckan="australia-southeast1-docker.pkg.dev/dsp-registry-410602/docker/ckan:${hash}"
KUBECONFIG=~/.kube/datahub-${env}.yml kubectl set image deployment/worker-${env} worker="australia-southeast1-docker.pkg.dev/dsp-registry-410602/docker/ckan:${hash}"