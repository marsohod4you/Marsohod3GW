import sys
import socket

num_args = len(sys.argv)
if num_args<3 :
	print("Need 2 or more arguments: 1) remote Device IP address, 2) number of UDP packets sents 3) optional up to 16 int values for packet bytes")
	sys.exit()

device_IP = sys.argv[1]
num_pkts = int(sys.argv[2])
if num_pkts <=0 :
	num_pkts = 1

packet = bytearray([0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x48,0x49,0x4A,0x4B,0x4C,0x4D,0x4E,0x4F])

i=0
while i<num_args-3 :
	val = int(sys.argv[i+3],0)
	packet[i]=val & 0xFF
	i=i+1

print("Remote Device IP",device_IP)
print("Number of packets for send ",num_pkts)
print("Packet:")
print(packet)

sock = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
#sock.bind((host_IP,0))
#sock.setsockopt(socket.SOL_SOCKET,socket.SO_BROADCAST,1)

i=0
while i<num_pkts:
	sock.sendto(packet,(device_IP,26985))
	i=i+1

print ('Sent UDP packets:',num_pkts)
