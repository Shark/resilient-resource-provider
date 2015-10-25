NS = sh4rk
REPO = rrp_calculator_provider
VERSION ?= latest

build:
	docker build -t $(NS)/$(REPO):$(VERSION) --force-rm=true .

default: build
