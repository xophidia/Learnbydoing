#!/bin/env/python
# Advent of code 2015 - niv 2
# xophidia

cpt = 0
with open('day2.txt','r') as my_file:
	for line in my_file.readlines() :
		temp = line.split('x')
		temp = map(int, temp)
		tri = sorted(temp)
		l = temp[0]
		w = temp[1]
		h = temp[2]
		cpt = cpt + (2 * l * w) + (2 * w * h) + (2 * l * h) + (tri[0] * tri[1])
	print "resultat -> %d" % cpt
my_file.close()