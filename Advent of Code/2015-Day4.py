#!/usr/bin/env python
# AdventofCode - Day4
# xophidia

import md5
chaine = "0123456789"

for i in chaine:
	for j in chaine:
		for k in chaine:
			for l in chaine:
				for m in chaine:
					for n in chaine:
							temp = md5.new("ckczppom" + i + j + k + l + m + n).hexdigest()
							if temp[:5] == '00000':
								print temp
								print " %c%c%c%c%c%c " % (i,j,k,l,m,n)
								
								 