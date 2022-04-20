#!/bin/bash
sed "s/tagVersion/$1/g" pods.yml > k8s-app-pod.yml
