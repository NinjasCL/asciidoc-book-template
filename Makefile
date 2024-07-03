.PHONY: html docbook pdf epub word build clean update

# TODO: Consider Docker https://github.com/asciidoctor/docker-asciidoctor

build b:
	@make clean
	@make html
	@make docbook
	@make pdf
	@make word
	@make epub

html h:
	@rm -rf docs/index.html
	@mkdir -p docs/book/assets
	@cp -R assets/highlight docs/
	@cp -R book/assets docs/book

	asciidoctor book.adoc -o docs/index.html

docbook d:
	@mkdir -p docs
	@rm -rf docs/book.xml
	asciidoctor -a media=prepress -b docbook book.adoc -o docs/book.xml

pdf p:
	@mkdir -p docs
	@rm -rf docs/book.pdf
	asciidoctor-pdf -a allow-uri-read=true -a source-highlighter=rouge -a rouge-style=monokai_sublime book.adoc -o docs/book.pdf

epub e:
	@mkdir -p docs
	@rm -rf docs/book.epub
	@cd docs && pandoc --from docbook --to epub --output book.epub book.xml

clean c:
	@rm -rf docs

update u:
	@./update.sh

word w:
	@mkdir -p docs
	@rm -rf docs/book.docx
	@cd docs && pandoc --from docbook --to docx --output book.docx book.xml
