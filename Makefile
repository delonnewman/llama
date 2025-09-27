test:
	carmel exec prove -r -Ilib -It/lib

console:
	carmel exec reply -Ilib

clean:
	rm -rf t/data

.PHONY: test console clean
