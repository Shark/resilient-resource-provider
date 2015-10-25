NS = sh4rk
REPO = consul
VERSION ?= latest

build:
	docker build -t $(NS)/$(REPO):$(VERSION) --force-rm=true .

default: build
