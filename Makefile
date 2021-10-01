SHELL := /bin/bash
.PHONY: docs build init apply

docs:
	@cd terraform && terraform-docs markdown table --output-file README.md --output-mode inject . 

test:
	@cd cloudfunctions && ./test.sh

apply:
	@cd terraform && terraform apply

init:
	@cd terraform && terraform init

plan:
	@cd terraform && terraform plan

start:
	@./start_server.sh