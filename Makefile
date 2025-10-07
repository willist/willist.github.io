.PHONY: build serve clean

build:
	podman run --rm -v "$(PWD):/srv/jekyll" docker.io/jekyll/jekyll:latest jekyll build

serve:
	podman run --rm -v "$(PWD):/srv/jekyll" -p 4000:4000 docker.io/jekyll/jekyll:latest jekyll serve --host 0.0.0.0 --force_polling

clean:
	rm -rf _site .jekyll-cache .jekyll-metadata
