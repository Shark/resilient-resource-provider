#!/bin/bash

set -e

docker pull ruby:2.2-onbuild
docker pull ubuntu:trusty

cd app && make && cd ..
cd calculator && make && cd ..
cd calculator_provider && make && cd ..
cd consul && make && cd ..

