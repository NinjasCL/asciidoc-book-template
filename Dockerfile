# See https://docs.asciidoctor.org/diagram-extension/latest/
# Tested on asciidoctor/docker-asciidoctor:1.78
FROM asciidoctor/docker-asciidoctor:latest

# Image comes with PlantUML and Grahpviz by default
# Add renderers of additional diagram languages

# Add dependencies
RUN apk add --update neovim nodejs npm
RUN apk add --no-cache \
    build-base \
    g++ \
    cairo-dev \
    jpeg-dev \
    giflib-dev \
    libpng-dev \
    pango-dev \
    bash \
    imagemagick \
    ttf-dejavu

# TODO: Consider installing bibtex for using: asciidoctor -r asciidoctor-bibtex

# DBML
# Since making ERD with PlantUML is cumbersome
RUN npm install -g @dbml/cli
RUN npm install -g @softwaretechnik/dbml-renderer

# Note Mermaid and BPMN needs Puppeteer
# So they are ommited for now in the default config

# BPMN
# Since making BPMN with PlantUML is not supported
# RUN npm install -g bpmn-js-cmd

# Mermaid for additional diagrams
# RUN npm install -g @mermaid-js/mermaid-cli

# Vega
# For making charts and graphs
RUN npm install --build-from-source -g vega-cli vega vega-lite vega-embed

WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
