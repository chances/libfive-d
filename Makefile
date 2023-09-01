ifdef OS
  OS := Windows
  ARCH := $(PROCESSOR_ARCHITECTURE)
  SOURCES := $(wildcard source/libfive/*.d)
else
  OS := $(shell uname -s)
  ARCH := $(shell uname -m)
ifeq ($(OS),Darwin)
  SED := gsed
else
  SED := sed
endif
  SOURCES := $(shell find source -name '*.d')
endif

ifeq (${OS},Darwin)
  LIBFIVE_ARTIFACTS += bin/libfive.dylib
else ifeq (${OS},Linux)
  LIBFIVE_ARTIFACTS += bin/libfive.so
else ifeq (${OS},Windows)
  LIBFIVE_ARTIFACTS += libfive.dll
else
  $(error Unsupported target platform: $(OS))
endif

.DEFAULT_GOAL = all

all: libfive $(SOURCES)
# TODO: dub build --root=examples/csg
	dub build --annotate

# Subprojects
libfive: $(LIBFIVE_ARTIFACTS)
.PHONY: libfive
subprojects/libfive:
	git submodule update --init --recursive

# TODO: Add checks for mac OS ARM artifacts
$(LIBFIVE_ARTIFACTS): subprojects/libfive.Makefile subprojects/libfive
ifneq (${OS},Windows)
	@make -C subprojects -f libfive.Makefile
	@mkdir -p bin
	@cp subprojects/libfive/build/libfive/src/$(@F) bin
else
	@if not exist bin mkdir bin
	@xcopy /Y .\\subprojects\\libfive\\build\\libfive\\src\\libfive.dll bin
	@xcopy /Y .\\subprojects\\libfive\\build\\libfive\\src\\libpng*.dll bin
	@xcopy /Y .\\subprojects\\libfive\\build\\libfive\\src\\zlib*.dll bin
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

docs: docs/sitemap.xml
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
