default:
	dzil build
test:
	# for some reason pod syntax checker requires --release flag
	dzil test --release
eecs490:
	TMP=$$(mktemp);\
	cp dist.ini $$TMP;\
	perl -pi -e 's/^license.*$$//s' dist.ini;\
	echo '-remove = License' >> dist.ini;\
	dzil build;\
	cp $$TMP dist.ini
# these are the build system's own dependencies
# (yeah...)
install-deps:
	dzil authordeps --missing | cpanm
clean:
	-rm README.txt
	dzil clean

.PHONY: default test eecs490 install-deps clean
