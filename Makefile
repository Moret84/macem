all: macem

macem: macem-x86 macem-arm64 
	lipo -create $^ -output $@

macem-x86: macem.swift
	swiftc -o $@ -target x86_64-apple-macos10.15 $^

macem-arm64: macem.swift
	swiftc -o $@ -target arm64-apple-macos10.15 $^

install: macem
	install $^ /usr/local/bin/

clean:
	@rm -rf macem macem-arm64 macem-x86

.PHONY: clean install
