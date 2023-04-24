default: install-deps test
	cabal install field-n-eq --installdir=./bin/
	mv bin/field-n-eq bin/field-n-eq?
	# final
	dzil build
test:
	# for some reason pod syntax checker requires --release flag
	dzil test --release
eecs490:
	TMP=$$(mktemp);\
	cp dist.ini $$TMP;\
	perl -pi -e 's/^license.*$$//s' dist.ini;\
	echo '-remove = License' >> dist.ini;\
	make;\
	cp $$TMP dist.ini
# bin/ dependencies
install-deps:
	# perl stuff
	## getting perl dependencies is really hard
	## this list is mostly manually curated and most likely nonexhaustive
	cpanm Carp::Assert
	cpanm Text::CSV
	cpanm JSON
	# ruby stuff
	bundler install
	# haskell stuff
	cabal build --only-dependencies
# these are the build system's own dependencies
# (yeah...)
install-build-deps:
	dzil authordeps --missing | cpanm
clean:
	dzil clean

.PHONY: default test eecs490 install-deps install-build-deps clean
