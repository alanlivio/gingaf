.PHONY: all build build-windows build-web test test-gingaf test-ncl-doc test-ncl-app test-ccws clean clean-gingaf clean-ncl-doc clean-ncl-app clean-ccws

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

clean: clean-ncl-doc clean-ncl-app clean-ccws clean-gingaf

clean-gingaf:
	flutter clean

clean-ncl-doc:
	cd ncl_doc && flutter clean

clean-ncl-app:
	cd ncl_app && flutter clean

clean-ccws:
	cd ccws && flutter clean
