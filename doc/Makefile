NAME=LovelyRPG

all: data
	dblatex -p ./style.xsl -s ./style.sty ${NAME}.xml

debug: data
	dblatex -p ./style.xsl -s ./style.sty -d --tmpdir=./temp ${NAME}.xml

validate: data
	xmllint --noout --xinclude --postvalid --noent ${NAME}.xml

data:
	./generate.sh

dataclean:
	rm -rf revision.data
	rm -rf history.data

clean: dataclean
	rm -rf temp

distclean: clean
	rm -rf ${NAME}.pdf

