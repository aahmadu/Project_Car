import RPi.GPIO as GPIO
import wiringpi

import MFRC522

import socket

import signal
import sys
import os

#for mapping values
from numpy import interp

#Setting up socket connection
sock = socket.socket (socket.AF_INET, socket.SOCK_STREAM)
#sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server_address = ('192.168.42.1', 5050)

try:
    print "starting up on %s port %s" % server_address
    sock.bind(server_address)
except socket.error:
    print "Already in use"
    GPIO.cleanup()
    sys.exit("Somthing Happened.")

sock.listen(1)
print "waiting for a connection"
connection, client_address = sock.accept()
print "connection from", client_address

#Wiringpi Setup for pwm pins BCM18(12) and BCM27(13)
wiringpi.wiringPiSetupGpio()
wiringpi.pinMode(18, wiringpi.GPIO.PWM_OUTPUT)
wiringpi.pinMode(13, wiringpi.GPIO.PWM_OUTPUT)
wiringpi.pwmSetMode(wiringpi.GPIO.PWM_MODE_MS)
wiringpi.pwmSetClock(192)
wiringpi.pwmSetRange(2000)

continue_reading = True

# Capture SIGINT for cleanup when the script is aborted
def end_read(signal,frame):
    pwm.stop()
    global continue_reading
    continue_reading = False
    GPIO.cleanup()
# Hook the SIGINT
signal.signal(signal.SIGINT, end_read)

# Setting up MFRC522 class
MIFAREReader = MFRC522.MFRC522()

if (os.fork()):
  while continue_reading:
    #Get data from phone
    rawData = connection.recv(3)
    # Need to close on this end or infinite loop waiting for data
    if len(rawData) < 2:
       continue
    rollPitch = [ord(rawData[0]), ord(rawData[1])]

    #ESC and servo write to pins
    ServoPosition = int(round(interp(rollPitch[1], [0,255], [100,200])))
    ESC_Value = int(round(interp(rollPitch[0], [0,255], [120,180])))
    wiringpi.pwmWrite(13, ServoPosition)
    wiringpi.pwmWrite(18, ESC_Value)
else:
  while continue_reading:
    # Scan for cards
    (status,TagType) = MIFAREReader.MFRC522_Request(MIFAREReader.PICC_REQIDL)
    # Get the UID of the card
    (status,uid) = MIFAREReader.MFRC522_Anticoll()
    # If we have the UID, continue
    if status == MIFAREReader.MI_OK:
	print uid
	package = ''.join( [ chr(y) for y in uid ] )
        connection.send(package)
