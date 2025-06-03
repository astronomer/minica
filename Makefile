# Variables
TAG := v1.1.0
LDFLAGS := -X main.buildVersion=$(TAG)
GO111MODULE := on
GO_VERSION := 1.22
BINARY_NAME := minica

# Default target
.DEFAULT_GOAL := help

# Silent mode
.SILENT:

# Phony targets
.PHONY: all help deps build clean test fmt lint dist dist-clean release check-go-version

# Help target
help:
	@echo "Available targets:"
	@echo "  all            - Build the binary (default)"
	@echo "  help           - Show this help message"
	@echo "  deps           - Download dependencies"
	@echo "  build          - Build the binary"
	@echo "  clean          - Remove build artifacts"
	@echo "  fmt            - Format code"
	@echo "  lint           - Run linters"
	@echo "  dist           - Build binaries for all platforms"
	@echo "  release        - Create release tarballs"

# Check Go version
check-go-version:
	@go version | grep -q "go$(GO_VERSION)" || (echo "Go $(GO_VERSION) is required" && exit 1)

# Dependencies
deps: check-go-version
	go mod tidy

# Build
build: check-go-version deps
	echo "Building $(BINARY_NAME)"
	go build -ldflags "$(LDFLAGS)" -o $(BINARY_NAME)

# Install
install: check-go-version deps
	echo "Installing $(BINARY_NAME)"
	go install -ldflags "$(LDFLAGS)"

# Clean
clean:
	rm -f $(BINARY_NAME)
	rm -rf dist
	rm -f minica-*.tar.gz

# Format
fmt: check-go-version
	go fmt ./...

# Lint
lint: check-go-version deps
	go vet ./...

# Distribution
dist-clean:
	rm -rf dist
	rm -f minica-*.tar.gz

dist: check-go-version deps dist-clean
	mkdir -p dist/alpine-linux/amd64 && GOOS=linux GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -a -tags netgo -installsuffix netgo -o dist/alpine-linux/amd64/minica
	mkdir -p dist/alpine-linux/ppc64le && GOOS=linux GOARCH=ppc64le go build -ldflags "$(LDFLAGS)" -a -tags netgo -installsuffix netgo -o dist/alpine-linux/ppc64le/minica
	mkdir -p dist/linux/amd64 && GOOS=linux GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o dist/linux/amd64/minica
	mkdir -p dist/linux/386 && GOOS=linux GOARCH=386 go build -ldflags "$(LDFLAGS)" -o dist/linux/386/minica
	mkdir -p dist/linux/armel && GOOS=linux GOARCH=arm GOARM=5 go build -ldflags "$(LDFLAGS)" -o dist/linux/armel/minica
	mkdir -p dist/linux/armhf && GOOS=linux GOARCH=arm GOARM=6 go build -ldflags "$(LDFLAGS)" -o dist/linux/armhf/minica
	mkdir -p dist/linux/arm64 && GOOS=linux GOARCH=arm64 go build -ldflags "$(LDFLAGS)" -o dist/linux/arm64/minica
	mkdir -p dist/linux/ppc64le && GOOS=linux GOARCH=ppc64le go build -ldflags "$(LDFLAGS)" -o dist/linux/ppc64le/minica
	mkdir -p dist/darwin/amd64 && GOOS=darwin GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o dist/darwin/amd64/minica
	mkdir -p dist/darwin/arm64 && GOOS=darwin GOARCH=arm64 go build -ldflags "$(LDFLAGS)" -o dist/darwin/arm64/minica
	mkdir -p dist/linux/s390x && GOOS=linux GOARCH=s390x go build -ldflags "$(LDFLAGS)" -o dist/linux/s390x/minica

# Release
release: dist
	tar -cvzf minica-alpine-linux-amd64-$(TAG).tar.gz -C dist/alpine-linux/amd64 minica
	tar -cvzf minica-alpine-linux-ppc64le-$(TAG).tar.gz -C dist/alpine-linux/ppc64le minica
	tar -cvzf minica-linux-amd64-$(TAG).tar.gz -C dist/linux/amd64 minica
	tar -cvzf minica-linux-386-$(TAG).tar.gz -C dist/linux/386 minica
	tar -cvzf minica-linux-armel-$(TAG).tar.gz -C dist/linux/armel minica
	tar -cvzf minica-linux-armhf-$(TAG).tar.gz -C dist/linux/armhf minica
	tar -cvzf minica-linux-arm64-$(TAG).tar.gz -C dist/linux/arm64 minica
	tar -cvzf minica-linux-ppc64le-$(TAG).tar.gz -C dist/linux/ppc64le minica
	tar -cvzf minica-darwin-amd64-$(TAG).tar.gz -C dist/darwin/amd64 minica
	tar -cvzf minica-darwin-arm64-$(TAG).tar.gz -C dist/darwin/arm64 minica
	tar -cvzf minica-linux-s390x-$(TAG).tar.gz -C dist/linux/s390x minica

# Alias for build
all: build