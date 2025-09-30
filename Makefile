test:
	carmel exec prove -r -Ilib -It/lib

console:
	carmel exec reply -Ilib

clean:
	rm -rf t/data

docs:
	pod2html --htmldir=./docs --podpath=./lib --verbose

.PHONY: test console clean docs
