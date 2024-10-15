// leds.cpp: определяет точку входа для консольного приложения.
//

#include "stdafx.h"
#include <string.h>
#include <windows.h>
#include "ftd2xx.h"

FT_HANDLE ftHandle; // Handle of the FTDI device
FT_STATUS ftStatus; // Result of each D2XX call
DWORD dwNumDevs; // The number of devices
DWORD dwNumBytesToRead = 0; // Number of bytes available to read in the driver's input buffer
DWORD dwNumBytesRead;
unsigned char byInputBuffer[1024]; // Buffer to hold data read from the FT2232H
DWORD dwNumBytesSent;
DWORD dwNumBytesToSend;
unsigned char byOutputBuffer[1024]; // Buffer to hold MPSSE commands and data to be sent to the FT2232H
int ft232H = 0; // High speed device (FTx232H) found. Default - full speed, i.e. FT2232D
DWORD dwClockDivisor = 0;
DWORD dwCount;

int ftdi_init()
{
FT_DEVICE ftDevice; 
DWORD deviceID; 
char SerialNumber[16+1]; 
char Description[64+1]; 

// Does an FTDI device exist?
printf("Checking for FTDI devices...\n");
ftStatus = FT_CreateDeviceInfoList(&dwNumDevs);

// Get the number of FTDI devices
if (ftStatus != FT_OK) // Did the command execute OK?
{
	printf("Error in getting the number of devices\n");
	return 1; // Exit with error
}

if (dwNumDevs < 1) // Exit if we don't see any
{
	printf("There are no FTDI devices installed\n");
	return 1; // Exist with error
}

printf("%d FTDI devices found - the count includes individual ports on a single chip\n", dwNumDevs);

ftHandle=NULL;

//go thru' list of devices
for(int i=0; i<dwNumDevs; i++)
{
	printf("Open port %d\n",i);
	ftStatus = FT_Open(i, &ftHandle);
	if (ftStatus != FT_OK)
	{
		printf("Open Failed with error %d\n", ftStatus);
		printf("If runing on Linux then try <rmmod ftdi_sio> first\n");
		continue;
	}

	FT_PROGRAM_DATA ftData;
	memset( &ftData,0, sizeof(ftData) );
	char ManufacturerBuf[32]; 
	char ManufacturerIdBuf[16]; 
	char DescriptionBuf[64]; 
	char SerialNumberBuf[16]; 

	ftData.Signature1 = 0x00000000; 
	ftData.Signature2 = 0xffffffff; 
	ftData.Version = 0x00000003;      //3 = FT2232H extensions
	ftData.Manufacturer = ManufacturerBuf; 
	ftData.ManufacturerId = ManufacturerIdBuf; 
	ftData.Description = DescriptionBuf; 
	ftData.SerialNumber = SerialNumberBuf; 
	ftStatus = FT_EE_Read(ftHandle,&ftData);
	if (ftStatus == FT_OK)
	{ 
		printf("\tDevice: %s\n\tSerial: %s\n", ftData.Description, ftData.SerialNumber);
		printf("\tDevice Type: %02X\n", ftData.IFAIsFifo7, ftData.IFBIsFifo7);
		if (ftData.IFAIsFifo7 && ftData.IFBIsFifo7)
		{
			printf("\tUse this device!\n");
			break;
		}
		else
		{
			FT_Close(ftHandle);
		}
	}
	else
	{
		printf("\tCannot read ext flash\n");
	}
}

if(ftHandle==NULL)
{
	printf("NO FTDI chip with FIFO function\n");
	return -1;
}

//ENABLE SYNC FIFO MODE
ftStatus |= FT_SetBitMode(ftHandle, 0xFF, 0x00);
ftStatus |= FT_SetBitMode(ftHandle, 0xFF, 0x40);

if (ftStatus != FT_OK)
{
	printf("Error in initializing1 %d\n", ftStatus);
	FT_Close(ftHandle);
	return 1; // Exit with error
}

UCHAR LatencyTimer = 2; //our default setting is 2
ftStatus |= FT_SetLatencyTimer(ftHandle, LatencyTimer); 
ftStatus |= FT_SetUSBParameters(ftHandle,0x10000,0x10000);
ftStatus |= FT_SetFlowControl(ftHandle,FT_FLOW_RTS_CTS,0x10,0x13);

if (ftStatus != FT_OK)
{
	printf("Error in initializing2 %d\n", ftStatus);
	FT_Close(ftHandle);
	return 1; // Exit with error
}

//return with success
return 0;
}

#define BLOCK_LEN (4096*16)
unsigned char sbuf[BLOCK_LEN];

int _tmain(int argc, _TCHAR* argv[])
{
	if( ftdi_init() )
	{
		printf("Cannot init FTDI chip\n");
		return -1;
	}
/*
	byOutputBuffer[0] = 0x51;
	FT_Write(ftHandle, byOutputBuffer, 1, &dwNumBytesSent);
	byOutputBuffer[0] = 0x52;
	FT_Write(ftHandle, byOutputBuffer, 1, &dwNumBytesSent);
	byOutputBuffer[0] = 0x53;
	FT_Write(ftHandle, byOutputBuffer, 1, &dwNumBytesSent);
	byOutputBuffer[0] = 0x54;
	FT_Write(ftHandle, byOutputBuffer, 1, &dwNumBytesSent);
*/
	byOutputBuffer[0] = 0x80;
	byOutputBuffer[1] = 0x91;
	byOutputBuffer[2] = 0xA2;
	byOutputBuffer[3] = 0xB3;
	byOutputBuffer[4] = 0xC4;
	byOutputBuffer[5] = 0xD5;
	byOutputBuffer[6] = 0xE6;
	byOutputBuffer[7] = 0xF7;

	FT_Write(ftHandle, byOutputBuffer, 8, &dwNumBytesSent);

	for(int i=0; i<BLOCK_LEN; i++)
		sbuf[i] = (i & 0xff);

		ULONGLONG ticks = GetTickCount64();
		int sz = 0;
		while(1)
		{
			FT_Write(ftHandle,sbuf,BLOCK_LEN,&dwNumBytesSent);
			sz += BLOCK_LEN;
			ULONGLONG t = GetTickCount64();
			if( (t-ticks) >= 1000)
			{
				//one second lapsed
				printf("sent %d bytes/sec\n",sz);
				ticks = t;
				sz = 0;
			}
		}

	return 0;
}
