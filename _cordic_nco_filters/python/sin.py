import serial
import time
import sys
import math

print("WIDTH = 5;")
print("DEPTH = 32;")
print("ADDRESS_RADIX = HEX;")
print("DATA_RADIX = HEX;")
print("CONTENT BEGIN")

i=0
while i<32 :
	a=math.pi*2/32*i
	r=31*(math.sin(a)+1.0)/2
	r=round(r)
	print(f'{i:0>4X}'," : ",f'{r:0>2X}',";")
	i=i+1
	
print("END")