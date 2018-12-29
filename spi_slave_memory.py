#!/usr/bin/python

import spidev
import time

class spi_slave_memory :
	spi = None
	
	_MAX_ADDRESS   = 0xFFF
	_READ_COMMAND  = 0x02
	_WRITE_COMMAND = 0x01

	# Constructor
	def __init__(self, spi_device=0, spi_channel=0, max_speed_hz = 5000000, mode = 0b00, debug=False): # 5MHz
		self.spi = spidev.SpiDev(spi_device, spi_channel)
		self.spi.max_speed_hz = max_speed_hz
		self.spi.mode = mode # CPOL,CPHA
		self.debug = debug
		
	def read_bytes(self, start_address=0x0000, num_bytes=1):
		if (self.debug == True):
			print "Called read_bytes"
		if (num_bytes == 0):
			print "Error: num_bytes must be larger than zero"
			return []
		else:
			byte0 = self._READ_COMMAND
			byte1 = (start_address & 0xFF00) >> 8
			byte2 = start_address & 0xFF
			filler_bytes = [0x00] * int(num_bytes)
			read_list = self.spi.xfer2([byte0,byte1,byte2] + filler_bytes)
			read_list[0:3] = []
			if (self.debug == True):
				address = start_address
				for read_byte in read_list:
					print "Address 0x%04x Read data 0x%02x" % (address,read_byte)
					address += 1
			return read_list
	
	def write_bytes(self, start_address=0x0000, write_byte_list=[]):
		byte0 = self._WRITE_COMMAND
		byte1 = (start_address & 0xFF00) >> 8
		byte2 = start_address & 0xFF
		self.spi.xfer2([byte0,byte1,byte2] + write_byte_list)
		if (self.debug == True):
			print "Called write_bytes"
			address = start_address
			for write_byte in write_byte_list:
				print "Wrote address 0x%04x data 0x%02x" % (address,write_byte)
				address += 1
		return 1


mem = spi_slave_memory(debug=True)
print "Write single address"
mem.write_bytes(start_address=0x000F,write_byte_list=[0xe1])
print "Read single address"
mem.read_bytes(start_address=0x000F,num_bytes=1)
print "Write multiple addresses"
mem.write_bytes(start_address=0x0005,write_byte_list=[0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef])
print "Read multiple addresses"
mem.read_bytes(start_address=0x0001,num_bytes=16)
