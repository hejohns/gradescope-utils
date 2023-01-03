default:
	dzil build
	./README.pl > README.txt
install-deps:
	dzil authordeps --missing | cpanm
clean:
	-rm README.txt

.PHONY: default install-deps clean
