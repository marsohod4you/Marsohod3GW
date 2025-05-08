import sys
import time
import socket

num_args = len(sys.argv)
if num_args<2 :
	print("Need 1 argument: remote device IP address")
	sys.exit()

device_IP = sys.argv[1]
print("My Remote Device IP",device_IP)

sock = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
#sock.bind((host_IP,0))

packet = bytearray([0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x48,0x49,0x4A,0x4B,0x4C,0x4D,0x4E,0x4F])
B=1
Bs = bytearray("........",encoding='ascii')
dir=1
while 1:
	j=0;
	Bs[0] = 0x2a if (B&0x01) else 0x2d
	Bs[1] = 0x2a if (B&0x02) else 0x2d
	Bs[2] = 0x2a if (B&0x04) else 0x2d
	Bs[3] = 0x2a if (B&0x08) else 0x2d
	Bs[4] = 0x2a if (B&0x10) else 0x2d
	Bs[5] = 0x2a if (B&0x20) else 0x2d
	Bs[6] = 0x2a if (B&0x40) else 0x2d
	Bs[7] = 0x2a if (B&0x80) else 0x2d
	print( Bs.decode(), end="\r" )
	packet[0] = B
	sock.sendto(packet,(device_IP,26985))
	if dir==1 :
		if B!=0xFF :
			B=(B<<1) | 1
		else :
			dir=0
			B=B>>1
	else :
		if B!=1 :
			B=B>>1
		else :
			B=(B>>1) | 1
			dir=1
	time.sleep(0.25)
