OS := $(shell uname -s)
ARCH := $(shell uname -m)
ifeq ($(OS),Darwin)
SED := gsed
else
SED := sed
endif
SOURCES := $(shell find source -name '*.d')

ifeq (${OS},Darwin)
LIBFIVE_ARTIFACTS += bin/libfive.dylib
else ifeq (${OS},Linux)
LIBFIVE_ARTIFACTS += bin/libfive.so
endif

.DEFAULT_GOAL = all

all: libfive
	dub build --annotate
	# TODO: dub build --root=examples/csg

# Subprojects
libfive: $(LIBFIVE_ARTIFACTS)
.PHONY: libfive
subprojects/libfive:
subprojects/libfive/libfive/include/libfive.h:
	git submodule update --init --recursive

$(LIBFIVE_ARTIFACTS): subprojects/libfive.Makefile subprojects/libfive
	@make -C subprojects -f libfive.Makefile
	@mkdir -p bin
ifeq (${OS},Darwin)
	# TODO: Add checks for ARM mac OS artifacts
	@cp subprojects/libfive/build/libfive/src/libfive.dylib bin
else ifeq (${OS},Linux)
	@cp subprojects/libfive/build/libfive/src/libfive.so bin
else
	# TODO: Dynamically build OS DLL
	$(error Unsupported target platform: $OS)
endif

# Documentation
PACKAGE_VERSION := 0.1.1
docs/sitemap.xml: $(SOURCES)
	dub build -b ddox
	@echo "Performing cosmetic changes..."
	# Navigation Sidebar
	@$(SED) -i -e "/<nav id=\"main-nav\">/r views/nav.html" -e "/<nav id=\"main-nav\">/d" `find docs -name '*.html'`
	# Page Titles
	@$(SED) -i "s/<\/title>/ - libfive<\/title>/" `find docs -name '*.html'`
	# Index
	@$(SED) -i "s/API documentation/API Reference/g" docs/index.html
	@$(SED) -i -e "/<h1>API Reference<\/h1>/r views/index.html" -e "/<h1>API Reference<\/h1>/d" docs/index.html
	# License Link
	@$(SED) -i "s/MPL-2.0/<a href=\"https:\/\/opensource.org\/license\/mpl-2-0\">Mozilla Public License 2.0<\/a>/" `find docs -name '*.html'`
	# Footer
	@$(SED) -i -e "/<p class=\"faint\">Generated using the DDOX documentation generator<\/p>/r views/footer.html" -e "/<p class=\"faint\">Generated using the DDOX documentation generator<\/p>/d" `find docs -name '*.html'`
	# Dub Package Version
	@echo `git describe --tags --abbrev=0`
	@$(SED) -i "s/DUB_VERSION/$(PACKAGE_VERSION)/g" `find docs -name '*.html'`
	@echo Done

docs: libfive docs/sitemap.xml
.PHONY: docs

# Cleanup
clean: clean-docs
	@rm -rf bin
.PHONY: clean

clean-docs:
	@echo "Cleaning generated documentation..."
	@rm -f docs.json
	@rm -f docs/sitemap.xml docs/file_hashes.json
	@rm -rf `find docs -name '*.html'`
.PHONY: clean-docs
