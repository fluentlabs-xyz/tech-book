.PHONY: dev build

dev:
	mdbook serve --open

build:
	mdbook build