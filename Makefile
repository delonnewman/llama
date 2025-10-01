test:
	prove -r -Ilib -It/lib

console:
	reply -Ilib

clean:
	rm -rf t/data

deps:
	cpm install --with-develop -g

.PHONY: test console clean
