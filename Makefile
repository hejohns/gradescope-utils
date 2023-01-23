default:
	./READ.ME.pl > README.txt
	dzil build
install-deps:
	dzil authordeps --missing | cpanm
clean:
	-rm README.txt

.PHONY: default install-deps clean
