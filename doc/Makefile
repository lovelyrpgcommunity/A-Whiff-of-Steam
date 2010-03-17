all:
	./generate.sh
	dblatex -p ./style.xsl -s ./style.sty LovelyRPG.xml

debug:
	./generate.sh
	dblatex -p ./style.xsl -s ./style.sty -d --tmpdir=./temp LovelyRPG.xml

clean:
	rm -rf revision.data
	rm -rf history.data
	rm -rf temp

distclean: clean
	rm -rf LovelyRPG.pdf

