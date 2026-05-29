.PHONY: all build build-windows build-web test test-gingaf test-ncl-doc test-ncl-app test-ccws run-examples run-examples-ncl-headless clean clean-gingaf clean-ncl-doc clean-ncl-app clean-ccws

all: build

build: build-windows build-web

build-windows:
	flutter build windows

build-web:
	flutter build web

test: test-ncl-doc test-ncl-app test-ccws test-gingaf

test-gingaf:
	flutter test

test-ncl-doc:
	cd ncl_doc && flutter test

test-ncl-app:
	cd ncl_app && flutter test

test-ccws:
	cd ccws && flutter test

NCL_EXAMPLES := $(wildcard examples/*.ncl)
HEADLESS_EXAMPLES := $(addsuffix -headless, $(NCL_EXAMPLES))

run-examples: $(NCL_EXAMPLES)

run-examples-headless: $(HEADLESS_EXAMPLES)

$(NCL_EXAMPLES):
	@echo ======================================================================
	@echo Running Example: $@
	@echo ======================================================================
	flutter run -d windows --dart-define="APP=$@"

%-headless:
	@echo ======================================================================
	@echo Running Headless NCL Example: $*
	@echo ======================================================================
	dart ./ncl_doc/lib/cli.dart $*

.PHONY: $(NCL_EXAMPLES) $(HEADLESS_EXAMPLES)

clean: clean-ncl-doc clean-ncl-app clean-ccws clean-gingaf

clean-gingaf:
	flutter clean

clean-ncl-doc:
	cd ncl_doc && flutter clean

clean-ncl-app:
	cd ncl_app && flutter clean

clean-ccws:
	cd ccws && flutter clean
