test:
	prove -r -Ilib -It/lib

console:
	reply -Ilib

clean:
	rm -rf t/data

.PHONY: test console clean
