.PHONY: html pdf server install bash word docbook docs files
# COMMAND=docker
COMMAND=podman

# Enter the server inside Docker
bash:
	@${COMMAND} run -it -u $(id -u):$(id -g) -v .:/documents/ adoc-book /bin/bash

# Install Docker Image
install i:
	@${COMMAND} build -t adoc-book .

# HTML
html h:
	@rm -rf docs/html
	@mkdir -p docs/html
	@cp -r resources/ docs/html
	@${COMMAND} run -it -u $(id -u):$(id -g) -v .:/documents/ adoc-book asciidoctor -r asciidoctor-diagram book.adoc -o docs/html/index.html --verbose

# Preview HTML Output
server s:
	@cd docs/html && echo "http://localhost:8000" && python3 -m http.server

# PDF, Docbook and Word

# Copy files
files f:
	@rm -rf docs/.asciidoctor
	@mkdir -p docs/.asciidoctor

	@find book -name '*.jpg' | xargs -I {} cp {} docs/.asciidoctor
	@find book -name '*.jpeg' | xargs -I {} cp {} docs/.asciidoctor
	@find book -name '*.png' | xargs -I {} cp {} docs/.asciidoctor
	@find book -name '*.svg' | xargs -I {} cp {} docs/.asciidoctor
	@find book -name '*.gif' | xargs -I {} cp {} docs/.asciidoctor

	@find resources/images -name '*.jpg' | xargs -I {} cp {} docs/.asciidoctor
	@find resources/images -name '*.jpeg' | xargs -I {} cp {} docs/.asciidoctor
	@find resources/images -name '*.png' | xargs -I {} cp {} docs/.asciidoctor
	@find resources/images -name '*.svg' | xargs -I {} cp {} docs/.asciidoctor
	@find resources/images -name '*.gif' | xargs -I {} cp {} docs/.asciidoctor

pdf p:
	@rm -rf docs/book.pdf
	@make files

	@${COMMAND} run -it -u $(id -u):$(id -g) -v .:/documents/ adoc-book asciidoctor-pdf -a allow-uri-read=true -a source-highlighter=rouge -a rouge-style=monokai_sublime -r asciidoctor-lists -r asciidoctor-diagram -r asciidoctor-bibtex -r asciidoctor-mathematical -a mathematical-format=svg book.adoc -o docs/book.pdf --verbose --trace

docbook d:
	@rm -rf docs/book.xml
	@make files
	@${COMMAND} run -it -u $(id -u):$(id -g) -v .:/documents/ adoc-book asciidoctor -b docbook -r asciidoctor-diagram -r asciidoctor-bibtex -r asciidoctor-mathematical -a mathematical-format=svg -a media=prepress book.adoc -o docs/book.xml --verbose

word w:
	@rm -rf docs/book.docx
	@make docbook
	@${COMMAND} run -it -u $(id -u):$(id -g) -v ./docs:/pandoc docker.io/dalibo/pandocker --from docbook --to docx --output book.docx book.xml
