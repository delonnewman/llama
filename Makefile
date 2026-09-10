test:
	prove -r -MCarp::Always -Ilib -It/lib

coverage:
	cover -test

console:
	reply -Ilib

clean:
	rm -rf t/data

docs:
	pods2html lib doc

deps:
	cpm install --with-develop -g

tidy:
	find . -name "*.pl" -o -name "*.pm" | xargs perltidy -b -bext='/'

.PHONY: test console clean docs tidy
