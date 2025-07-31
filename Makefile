test:
	prove -r -Ilib

console:
	reply -Ilib

clean:
	rm -rf t/data

.PHONY: test console clean
