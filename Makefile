default:
	./READ.ME.pl > README.txt
	dzil build
eecs490:
	./READ.ME.pl > README.txt
	TMP=$$(mktemp);\
	cp dist.ini $$TMP;\
	perl -pi -e 's/^license.*$$//s' dist.ini;\
	echo '-remove = License' >> dist.ini;\
	dzil build;\
	cp $$TMP dist.ini

install-deps:
	dzil authordeps --missing | cpanm
clean:
	-rm README.txt

.PHONY: default eecs490 install-deps clean
