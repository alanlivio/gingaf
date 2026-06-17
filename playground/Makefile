.PHONY: test setup run build

setup:
	npm install

test:
	@echo "No tests in playground yet"

run:
	$(MAKE) -C ../ginga build-web BASE_HREF=/gingaf/playground/player/
	cmd /c "mkdir public\player 2>nul || exit 0"
	cmd /c "xcopy /e /i /y ..\ginga\build\web public\player"
	npm run dev

build:
	$(MAKE) -C ../ginga build-web BASE_HREF=/gingaf/playground/player/
	cmd /c "mkdir public\player 2>nul || exit 0"
	cmd /c "xcopy /e /i /y ..\ginga\build\web public\player"
	npm run build
