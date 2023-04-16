all: tailwindcss
	mkdir -p ./dist
	cp src/* dist/
	./tailwindcss -i src/styles.css -o dist/styles.css --minify

tailwindcss:
	curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-macos-arm64
	chmod +x tailwindcss-macos-arm64
	mv tailwindcss-macos-arm64 tailwindcss
