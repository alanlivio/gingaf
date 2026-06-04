.PHONY: all build build-windows build-web test clean run-example run-example-headless run-mainav check-app download-puc-examples

all: build

build: 
	flutter build windows

build-windows: build/windows/x64/runner/Release/gingaf.exe

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))
DART_FILES := $(call rwildcard,lib ccws ncl_doc ncl_app,*.dart)

build/windows/x64/runner/Release/gingaf.exe: $(DART_FILES)
	flutter build windows

build-web:
	flutter build web

test:
	cd ncl_doc && flutter test
	cd ncl_app && flutter test
	cd ccws && flutter test
	flutter test

check-app:
	$(if $(app),,$(error Please specify app (e.g. app=video.ncl)))
	$(eval APP_FILE := $(if $(findstring examples/,$(app)),$(app),examples/$(app)))
	$(eval APP_FILE := $(APP_FILE)$(if $(filter %.ncl %.html,$(APP_FILE)),,.ncl))
	$(if $(wildcard $(APP_FILE)),,$(error File $(APP_FILE) does not exist))

run-example: check-app build/windows/x64/runner/Release/gingaf.exe
	@echo ======================================================================
	@echo Running Example: $(APP_FILE)
	@echo ======================================================================
	@set APP=$(APP_FILE)&& start /wait .\build\windows\x64\runner\Release\gingaf.exe

run-example-headless: check-app
	@echo ======================================================================
	@echo Running Headless NCL Example: $(APP_FILE)
	@echo ======================================================================
	@dart ./ncl_doc/lib/cli.dart $(APP_FILE)

run-mainav: build/windows/x64/runner/Release/gingaf.exe
	@echo ======================================================================
	@echo Running MainAV Test
	@echo ======================================================================
	@set APP=&& set MAINAV=https://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4&& start /wait .\build\windows\x64\runner\Release\gingaf.exe

clean:
	cd ncl_doc && flutter clean
	cd ncl_app && flutter clean
	cd ccws && flutter clean
	flutter clean

download-puc-examples:
	python examples/download_puc_examples.py


