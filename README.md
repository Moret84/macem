# mac OS certificate manager

**ma**c OS **ce**rtificate **m**anager (macem) is a tool to help sharing certificates and private keys accross installs.
It replaces the security export command previously used to export identities (certificates and associated private keys).

## Dependencies

- swiftc
- make

## Install

```
$ make && sudo make install
````

## Usage

```
    macem -P <exportPassword> -o <targetPath>
        with: 
            exportPassword: the password that protect the resulting .p12
            targetPath: the target file name
```

## Informations

To use unattended (typically through ssh), you must have exported **graphically** the key once.  
You also have to add macem to the list of allowed applications for a given key.
