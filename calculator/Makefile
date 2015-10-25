NS = sh4rk
REPO = rrp_calculator
VERSION ?= latest

build:
	docker build -t $(NS)/$(REPO):$(VERSION) --force-rm=true .

default: build
