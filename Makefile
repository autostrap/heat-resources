.PHONY: all clean doc lint

RESOURCES := $(shell find . -name '*.yaml' | grep -v env.yaml | sed 's/\.yaml$ //')
ADOC := $(patsubst %, %.adoc, ${RESOURCES})
YAML := $(patsubst %, %.yaml, ${RESOURCES})
HTML := site/index.html

# Only include env.yaml for now, since building/checking documentation requires
# commands that might not be present

doc: ${HTML}

all: env.yaml

lint: ${YAML}
	for i in ${YAML}; do heat_doclint $$i; done

site/:
	mkdir -p site

$(HTML): site/ $(ADOC) index.adoc
	asciidoctor -b html5 -o $@ index.adoc

env.yaml:
	bin/gen_registry ${YAML} > $@

index.adoc: index.template.adoc
	cp index.template.adoc index.adoc
	for i in ${ADOC}; do echo "include::$${i}[]\n" >> index.adoc; done

%.adoc: %.yaml
	 heat2adoc --prefix AS -o $@ $<

clean:
	rm -f ${ADOC}
	rm -f env.yaml
	rm -rf site/
