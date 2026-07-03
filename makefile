server:
	hugo server --minify --gc --buildDrafts --renderToMemory --disableFastRender --port 1414 --bind 0.0.0.0


update-submodule:
	git submodule update --remote --merge


oss:
	rm -rf /tmp/blog
	hugo build --minify --destination /tmp/blog
	ossutil rm -rf oss://kingtuo123 --include "*"
	ossutil cp -rf /tmp/blog/ oss://kingtuo123
