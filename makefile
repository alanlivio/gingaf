.PHONY: all build build-windows build-web test clean run-examples run-examples-ncl-headless 

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

NCL_EXAMPLES := $(wildcard examples/*.ncl)
HEADLESS_EXAMPLES := $(addsuffix -headless, $(NCL_EXAMPLES))

run-examples: $(NCL_EXAMPLES)

run-examples-headless: $(HEADLESS_EXAMPLES)

$(NCL_EXAMPLES): build/windows/x64/runner/Release/gingaf.exe
	@echo ======================================================================
	@echo Running Example: $@
	@echo ======================================================================
	@set APP=$@&& start /wait .\build\windows\x64\runner\Release\gingaf.exe

run-mainav: build/windows/x64/runner/Release/gingaf.exe
	@echo ======================================================================
	@echo Running MainAV Test
	@echo ======================================================================
	@set APP=&& set MAINAV=https://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4&& start /wait .\build\windows\x64\runner\Release\gingaf.exe

$(HEADLESS_EXAMPLES): %-headless:
	@echo ======================================================================
	@echo Running Headless NCL Example: $*
	@echo ======================================================================
	@dart ./ncl_doc/lib/cli.dart $*

.PHONY: $(NCL_EXAMPLES) $(HEADLESS_EXAMPLES) run-examples run-examples-headless

clean:
	cd ncl_doc && flutter clean
	cd ncl_app && flutter clean
	cd ccws && flutter clean
	flutter clean
