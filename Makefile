test:
	prove -r -Ilib -It/lib

console:
	reply -Ilib

clean:
	rm -rf t/data

docs:
	pod2html --htmldir=./docs --podpath=./lib --verbose

.PHONY: test console clean docs
