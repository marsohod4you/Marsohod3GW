

def convert( fname ) :
	file1 = open( fname, 'r')
	Lines = file1.readlines()

	N=0
	count = 0
	str=""
	for line in Lines:
		line=line.rstrip()
		if line[0]=="#" :
			continue
		count += 1
		str=line+str
		if count==32 :
			strHex = "%0.2X" % N
			strFull="defparam sp_inst_0.INIT_RAM_"+strHex+" = 256'h"+str+";"
			print(strFull)
			N=N+1
			str=""
			count=0

print("BROM0")
convert("build/fw-brom_0.mi")
print("BROM1")
convert("build/fw-brom_1.mi")
print("BROM2")
convert("build/fw-brom_2.mi")
print("BROM3")
convert("build/fw-brom_3.mi")


