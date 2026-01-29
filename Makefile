POETRY := poetry
DOCKER_IMAGE := scripts/runtime.Dockerfile
DOCKER_NAME = oxylus-server


# Build python package
.PHONY: package
package:
	@echo "Build Python package..."
	$(POETRY) build
	@echo "Python package built."


# Build docker image
.PHONY: docker-runtime
docker-runtime: package
	@echo "Building Docker image: $(DOCKER_IMAGE)..."
	docker build -f $(DOCKER_IMAGE) -t oxylus-server:latest ./
	@echo "Docker image built successfully."


# Clean targets
.PHONY: clean
clean:
	@echo "Clean build files"
	@rm -rf dist *.egg-info
	@echo "Clean complete."
