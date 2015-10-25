NS = sh4rk
REPO = rrp_app
VERSION ?= latest

build:
	docker build -t $(NS)/$(REPO):$(VERSION) --force-rm=true .

default: build
