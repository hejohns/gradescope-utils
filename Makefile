default:
	dzil build
	./READ.ME.pl > README.txt
install-deps:
	dzil authordeps --missing | cpanm
clean:
	-rm README.txt

.PHONY: default install-deps clean
