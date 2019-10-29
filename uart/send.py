#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys, serial
if len(sys.argv) != 2:
	print('Error')
	sys.exit(2)
try:
	device = '/dev/' + sys.argv[1]
	port = serial.Serial(device)
	port.baudrate = 19200
	port.bytesize = 8
	port.parity = 'N'
	port.stopbits = 1
	port.timeout = 0.2
	port.xonxoff = False
	port.rtscts = False
	port.dsrdtr = False
except serial.SerialException:
	print('Chto-to poshlo ne tak')
	sys.exit(2)
#print('Всё идёт по плану. Устройство {0} подключено'.format(device))
print('All OK, device {0} connected'.format(device))
print(str(port) + '\n')
s = 0
try:
	while True:
		msg = input()
		msg_to_send = msg.encode('utf8')
		port.write(msg_to_send)
except KeyboardInterrupt:
	sys.exit(0)
