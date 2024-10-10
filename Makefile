.PHONY: html pdf server install bash word docbook docs

html h:
	@rm -rf docs/html
	@mkdir -p docs/html
	@cp -r resources/ docs/html
	@docker run -it -u $(id -u):$(id -g) -v .:/documents/ adoc-book asciidoctor -r asciidoctor-diagram book.adoc -o docs/html/index.html --verbose

pdf p:
	@rm -rf docs/book.pdf
	@rm -rf docs/.asciidoctor
	@make docs
# Copy files
	@find book -name '*.jpg' | xargs -I {} cp {} docs/.asciidoctor
	@find book -name '*.jpeg' | xargs -I {} cp {} docs/.asciidoctor
	@find book -name '*.png' | xargs -I {} cp {} docs/.asciidoctor
	@find book -name '*.svg' | xargs -I {} cp {} docs/.asciidoctor
	@find book -name '*.gif' | xargs -I {} cp {} docs/.asciidoctor

	@docker run -it -u $(id -u):$(id -g) -v .:/documents/ adoc-book asciidoctor-pdf -a allow-uri-read=true -a source-highlighter=rouge -a rouge-style=monokai_sublime -r asciidoctor-diagram -r asciidoctor-mathematical -a mathematical-format=svg book.adoc -o docs/book.pdf --verbose

server s:
	@cd docs/html && echo "http://localhost:8000" && python3 -m http.server

# Enter the server inside Docker
bash:
	@docker run -it -u $(id -u):$(id -g) -v .:/documents/ adoc-book /bin/bash

install i:
	@docker build -t adoc-book .

docs:
	@mkdir -p docs/.asciidoctor

docbook d:
	@make docs
	@rm -rf docs/book.xml
	@docker run -it -u $(id -u):$(id -g) -v .:/documents/ adoc-book asciidoctor -b docbook -r asciidoctor-diagram -r asciidoctor-mathematical -a mathematical-format=svg -a media=prepress book.adoc -o docs/book.xml --verbose

word w:
	@make docs
	@rm -rf docs/book.docx
	@cd docs && pandoc --from docbook --to docx --output book.docx book.xml
