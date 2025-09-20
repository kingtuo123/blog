server:
	hugo server --minify --gc --renderToMemory --disableFastRender --port 1414 --bind 0.0.0.0


update-submodule:
	git submodule update --remote --merge
