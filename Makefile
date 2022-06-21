build:
	docker build -t omnia .
.PHONY: build

run:
	docker run -it --rm -v "$$(pwd)"/lib:/home/omnia/lib -v "$$(pwd)"/test:/home/omnia/test omnia /bin/bash
.PHONY: run

build-and-run: build run
	@echo "Ran."
.PHONY: build-and-run

build-test:
	docker-compose -f .github/docker-compose-e2e-tests.yml build --no-cache omnia_e2e
.PHONY: build-test

test: build-test # Run tests 
	docker-compose -f .github/docker-compose-e2e-tests.yml run omnia_e2e
.PHONY: test
