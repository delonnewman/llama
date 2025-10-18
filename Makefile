test:
	prove -r -MCarp::Always -Ilib -It/lib

console:
	reply -Ilib

clean:
	rm -rf t/data

docs:
	pod2html --htmldir=./docs --podpath=./lib --verbose

deps:
	cpm install --with-develop -g

.PHONY: test console clean docs
