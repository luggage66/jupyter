RELEASE_NAME ?= jupyterhub
JUPYTERHUB_NAMESPACE ?= jupyterhub
JUPYTERHUB_HELM_CHART ?= jupyterhub/jupyterhub
JUPYTERHUB_HELM_CHART_VERSION ?= 0.8.2

CIRCLE_SHA1 ?= $(shell git rev-parse HEAD)
SHORT_SHA ?= $(shell echo ${CIRCLE_SHA1} | cut -c -7)
DOCKER_IMAGE_TAG ?= $(SHORT_SHA)
DOCKER_IMAGE_NAME ?= us.gcr.io/prod-8ca0936b/jupyter-dotnet

.PHONY: helm-update help docker docker-push deploy

help: ## print this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
		| sed 's/^.*\/\(.*\)/\1/' \
		| awk 'BEGIN {FS = ":[^:]*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

docker: ## Build docker image
	docker build . -f try.Dockerfile -t $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)

docker-push:
	docker push $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)

helm-update:
	helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
	helm repo update

deploy: ## Deploy jupyterhub to kubernetes
	helm upgrade --install $(RELEASE_NAME) $(JUPYTERHUB_HELM_CHART) \
		--version $(JUPYTERHUB_HELM_CHART_VERSION) \
		--namespace $(JUPYTERHUB_NAMESPACE) \
		-f jupyterhub-values.yaml

template: ## view helm template output
	helm template --name $(RELEASE_NAME) $(JUPYTERHUB_HELM_CHART) \
		--version $(JUPYTERHUB_HELM_CHART_VERSION) \
		--namespace $(JUPYTERHUB_NAMESPACE) \
		-f jupyterhub-values.yaml