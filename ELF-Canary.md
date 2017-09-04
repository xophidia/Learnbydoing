# Utilisation du Canary sur un ELF 32/64 #

Ci-dessous le code est vulnérable à un dépassement de tampon. Nous allons par un exemple comprendre le mode de fonctionnement de la protection canary. Pour activer le canary lors de la compilation ajoutez **-fstack-protector**.

Le **canary** est une des nombreuses protections disponibles pour les executables.
Elle ajoute un nombre aléatoire qui est verifié durant l'exécution. Si la valeur est modifiée le programme fini sur une erreur et rend l'exploitation d'un dépassement de tampon classique inefficace.

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int verification(char *password)
{
int flag = 0;
char password_buffer[16];
strcpy(password_buffer, password);
if (strcmp(password_buffer, "oiseau") == 0) flag = 1;
return flag;
}

int main (int argc, char** argv)
{
(verification(argv[1])) ? printf ("Bien joué") : printf ("Erreur");
return 0;
}
```

Premier code sans canary :

```asm
   0x56555600 <+0>:	push   ebp
   0x56555601 <+1>:	mov    ebp,esp
   0x56555603 <+3>:	push   ebx
   0x56555604 <+4>:	sub    esp,0x24
   0x56555607 <+7>:	call   0x565554d0 <__x86.get_pc_thunk.bx>
   0x5655560c <+12>:	add    ebx,0x19f4
   0x56555612 <+18>:	mov    DWORD PTR [ebp-0xc],0x0
   0x56555619 <+25>:	sub    esp,0x8
   0x5655561c <+28>:	push   DWORD PTR [ebp+0x8]
   0x5655561f <+31>:	lea    eax,[ebp-0x1c]
   0x56555622 <+34>:	push   eax
   0x56555623 <+35>:	call   0x56555460 <strcpy@plt>
   0x56555628 <+40>:	add    esp,0x10
   0x5655562b <+43>:	sub    esp,0x8
   0x5655562e <+46>:	lea    eax,[ebx-0x18c0]
   0x56555634 <+52>:	push   eax
   0x56555635 <+53>:	lea    eax,[ebp-0x1c]
   0x56555638 <+56>:	push   eax
   0x56555639 <+57>:	call   0x56555440 <strcmp@plt>
   0x5655563e <+62>:	add    esp,0x10
   0x56555641 <+65>:	test   eax,eax
   0x56555643 <+67>:	jne    0x5655564c <verification+76>
   0x56555645 <+69>:	mov    DWORD PTR [ebp-0xc],0x1
   0x5655564c <+76>:	mov    eax,DWORD PTR [ebp-0xc]
   0x5655564f <+79>:	mov    ebx,DWORD PTR [ebp-0x4]
   0x56555652 <+82>:	leave
   0x56555653 <+83>:	ret
```

Avec canary d'activé

```asm
0x56555650 <+0>:	push   ebp
   0x56555651 <+1>:	mov    ebp,esp
   0x56555653 <+3>:	push   ebx
   0x56555654 <+4>:	sub    esp,0x34
   0x56555657 <+7>:	call   0x56555520 <__x86.get_pc_thunk.bx>
   0x5655565c <+12>:	add    ebx,0x19a4
   0x56555662 <+18>:	mov    eax,DWORD PTR [ebp+0x8]
   0x56555665 <+21>:	mov    DWORD PTR [ebp-0x2c],eax
   0x56555668 <+24>:	mov    eax,gs:0x14
   0x5655566e <+30>:	mov    DWORD PTR [ebp-0xc],eax
   0x56555671 <+33>:	xor    eax,eax
   0x56555673 <+35>:	mov    DWORD PTR [ebp-0x20],0x0
   0x5655567a <+42>:	sub    esp,0x8
   0x5655567d <+45>:	push   DWORD PTR [ebp-0x2c]
   0x56555680 <+48>:	lea    eax,[ebp-0x1c]
   0x56555683 <+51>:	push   eax
   0x56555684 <+52>:	call   0x565554b0 <strcpy@plt>
   0x56555689 <+57>:	add    esp,0x10
   0x5655568c <+60>:	sub    esp,0x8
   0x5655568f <+63>:	lea    eax,[ebx-0x1830]
   0x56555695 <+69>:	push   eax
   0x56555696 <+70>:	lea    eax,[ebp-0x1c]
   0x56555699 <+73>:	push   eax
   0x5655569a <+74>:	call   0x56555480 <strcmp@plt>
   0x5655569f <+79>:	add    esp,0x10
   0x565556a2 <+82>:	test   eax,eax
   0x565556a4 <+84>:	jne    0x565556ad <verification+93>
   0x565556a6 <+86>:	mov    DWORD PTR [ebp-0x20],0x1
   0x565556ad <+93>:	mov    eax,DWORD PTR [ebp-0x20]
   0x565556b0 <+96>:	mov    edx,DWORD PTR [ebp-0xc]
   0x565556b3 <+99>:	xor    edx,DWORD PTR gs:0x14
   0x565556ba <+106>:	je     0x565556c1 <verification+113>
   0x565556bc <+108>:	call   0x565557a0 <__stack_chk_fail_local>
   0x565556c1 <+113>:	mov    ebx,DWORD PTR [ebp-0x4]
   0x565556c4 <+116>:	leave
   0x565556c5 <+117>:	ret
```

Le canary est socké en position ebp-0xc (ligne +24 et +30) puis est
comparé avec lui même via un xor (ligne + 99). Si  la valeur est
différente, la prochaine instruction est call 0x565557a0 <__stack_chk_fail_local>.


Pour exploiter le code ci-dessus et contrôler EIP, nous avons besoin de :

- > 28 * "A" + EBP + EIP

Ci-dessous un image de la mémoire après le strcpy. 0xffffd2ac est l'adresse du buffer et nous observons les 28 lettres A puis ebp et eip.

```
0xffffd2ac:	0x61616161	0x61616161	0x61616161	0x61616161
0xffffd2bc:	0x61616161	0x61616161	0x61616161	0xffffd2e8(EBP)
0xffffd2cc:	0x565556f3(EIP)


0x565556ee <+40>:	call   0x56555650 <verification>
0x565556f3 <+45>:	add    esp,0x10
```

## Concernant le programme sans protection ##

Nous provoquons l'écrasement d'eip

```r aaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbcccc```


```
eax            0x61616161	0x61616161
ecx            0x6f	0x6f
edx            0xffffd29c	0xffffd29c
ebx            0x61616161	0x61616161
esp            0xffffd2c0	0xffffd2c0
ebp            0x62626262	0x62626262
esi            0x2	0x2
edi            0xf7fb2000	0xf7fb2000
eip            0x63636363	0x63636363
```
Nous voyons bien qu'ebp et eip sont contôlés, il ne reste plus qu'à exploiter.

## Concernant le programme avec protection ##

```r aaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbcccc```

A la ligne +106 nous observons la valeur du canary via **x/x $ebp-0xc**
et nous obtenons :

```
gdb-peda$ x/wx $ebp-0xc
0xffffd2ac:	0x61616161
```

Le canary étant écrasé, le programme provoque une erreur **__stack_chk_fail_local**.

## Vérification/Contournement ##

Nous relancons le programme avec les mêmes données:

```
r aaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbcccc
```

puis une pause ligne 30 afin d'obtenir la valeur du canary

```
b *0x5655566e
0x5655566e <verification+30>:	mov    DWORD PTR [ebp-0xc],eax

Quelle est la valeur du canary ?

x/x $edx

0x19525700
```

Au moment de la vérification, nous posons un point d'arrêt ligne 99 afin de modifier la valeur du registrer afin qu'il corresponde au canary:

```
0x565556b3 <+99>:    xor    edx,DWORD PTR gs:0x14

puis modifions la valeur d'edx

set $edx=0x19525700

et continuons le programme

0x63636363 in ?? ()

```

EIP est controlé et le canary evité.
