.PHONY: all build build-windows build-web test clean run-example run-example-headless run-playground run-mainav check-app download-puc-examples

all: build

build: 
	cd ginga && flutter build windows

build-windows: ginga/build/windows/x64/runner/Release/gingaf.exe

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))
DART_FILES := $(call rwildcard,ncl_doc ginga,*.dart)

ginga/build/windows/x64/runner/Release/gingaf.exe: $(DART_FILES)
	cd ginga && flutter build windows

build-web:
	cd ginga && flutter build web

test:
	cd ncl_doc && flutter test
	cd ginga && flutter test

check-app:
	$(if $(app),,$(error Please specify app (e.g. app=video.ncl)))
	$(eval APP_EXAMPLE := $(if $(findstring examples/,$(app)),$(app),examples/$(app)))
	$(eval APP_EXAMPLE := $(APP_EXAMPLE)$(if $(filter %.ncl %.html,$(APP_EXAMPLE)),,.ncl))
	$(if $(wildcard $(APP_EXAMPLE)),,$(error File $(APP_EXAMPLE) does not exist))

ginga/examples:
	cmd /c "mklink /J ginga\\examples examples" || ln -s ../examples ginga/examples

run-example: check-app ginga/examples
	@echo ======================================================================
	@echo Running Example: $(APP_EXAMPLE)
	@echo ======================================================================
	cd ginga && flutter run --no-pub -d windows --dart-define="APP=$(APP_EXAMPLE)"

run-example-headless: check-app
	@echo ======================================================================
	@echo Running Headless NCL Example: $(APP_EXAMPLE)
	@echo ======================================================================
	@dart ./ncl_doc/lib/main.dart $(APP_EXAMPLE)

run-playground: build-web
	@echo ======================================================================
	@echo Starting Ginga Playground
	@echo ======================================================================
	cmd /c "mkdir ginga-playground\public\player 2>nul || exit 0"
	cmd /c "xcopy /e /i /y ginga\build\web ginga-playground\public\player"
	cd ginga-playground && npm run dev

build-playground: build-web
	@echo ======================================================================
	@echo Building Ginga Playground
	@echo ======================================================================
	cmd /c "mkdir ginga-playground\public\player 2>nul || exit 0"
	cmd /c "xcopy /e /i /y ginga\build\web ginga-playground\public\player"
	cd ginga-playground && npm run build

clean:
	cd ncl_doc && flutter clean
	cd ginga && flutter clean

download-puc-examples:
	python examples/download_puc_examples.py
