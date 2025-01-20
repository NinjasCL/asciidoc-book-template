.PHONY: html pdf server install bash word docbook docs files

# Enter the server inside Docker
bash:
	@docker run -it -u $(id -u):$(id -g) -v .:/documents/ adoc-book /bin/bash

# Install Docker Image
install i:
	@docker build -t adoc-book .

# HTML
html h:
	@rm -rf docs/html
	@mkdir -p docs/html
	@cp -r resources/ docs/html
	@docker run -it -u $(id -u):$(id -g) -v .:/documents/ adoc-book asciidoctor -r asciidoctor-diagram book.adoc -o docs/html/index.html --verbose

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

	@docker run -it -u $(id -u):$(id -g) -v .:/documents/ adoc-book asciidoctor-pdf -a allow-uri-read=true -a source-highlighter=rouge -a rouge-style=monokai_sublime -r asciidoctor-diagram -r asciidoctor-bibtex -r asciidoctor-mathematical -a mathematical-format=svg book.adoc -o docs/book.pdf --verbose

docbook d:
	@rm -rf docs/book.xml
	@make files
	@docker run -it -u $(id -u):$(id -g) -v .:/documents/ adoc-book asciidoctor -b docbook -r asciidoctor-diagram -r asciidoctor-bibtex -r asciidoctor-mathematical -a mathematical-format=svg -a media=prepress book.adoc -o docs/book.xml --verbose

word w:
	@rm -rf docs/book.docx
	@make docbook
	@cd docs && pandoc --from docbook --to docx --output book.docx book.xml
