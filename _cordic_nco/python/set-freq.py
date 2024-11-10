import serial
import time
import sys
#from fxpmath import Fxp

if len(sys.argv)<3 :
	print("Not enough arguments, need serial port name param and freq to be set in NCO")
port_name = sys.argv[1]
print("Serial port: ",port_name)

need_freq = int( sys.argv[2] )
need_freq_float = float(need_freq)
print("NCO freq: ",need_freq_float)

base_freq=50000000
acc_increment_float = need_freq_float / base_freq
print("NCO accumulator increment (float): ",acc_increment_float)

#x = Fxp(acc_increment, True, 32, 31)
#x.bin(frac_dot=True)

# N must be floating, less then 1.0
def float2fixedp(N) :
	num_bits_fixedp = 32
	frac_part = 0
	i = 0
	t = 0.5
	while i < num_bits_fixedp :
		if ((N - t) >= 0) :
			N = N - t;
			frac_part = frac_part | (1 << (num_bits_fixedp - 1 - i))
		t = t / 2
		i=i+1
	return frac_part

acc_incr = float2fixedp(acc_increment_float)
print("NCO accumulator increment (hex32): ",f'{acc_incr:0>8X}')
print("NCO accumulator increment (bin32): ",f'{acc_incr:0>32b}')

#make protocol CMD packet to set NCO freq in Hardware 
ba=bytearray( [ 0,0,0,0,0 ] )
ba[0] = 0x80
ba[1] = (acc_incr>> 0)&0xFF
ba[2] = (acc_incr>> 8)&0xFF
ba[3] = (acc_incr>>16)&0xFF
ba[4] = (acc_incr>>24)&0xFF
if ba[1]&0x80 :
	ba[0] = ba[0]|1
if ba[2]&0x80 :
	ba[0] = ba[0]|2
if ba[3]&0x80 :
	ba[0] = ba[0]|4
if ba[4]&0x80 :
	ba[0] = ba[0]|8
ba[1]=ba[1]&0x7F
ba[2]=ba[2]&0x7F
ba[3]=ba[3]&0x7F
ba[4]=ba[4]&0x7F

print("CMD packet:",bytes(ba).hex())

port = serial.Serial()
port.baudrate=12000000
port.port=port_name
port.bytesize=8
port.parity='N'
port.stopbits=1
port.open()
port.write( ba )
port.close()
