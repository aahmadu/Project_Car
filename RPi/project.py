#!/usr/bin/env python
# -*- coding: utf8 -*-

import RPi.GPIO as GPIO
import MFRC522
import signal

import socket

import sys

#for mapping values
from numpy import interp

#Setting up socket connection
sock = socket.socket ()
server_address = ('10.1.3.50', 5050)

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

#Servo Setup
GPIO.setmode(GPIO.BOARD)
GPIO.setup(11, GPIO.OUT)
frequencyHertz=50
pwm = GPIO.PWM(11,frequencyHertz)
msPerCycle = 1000/frequencyHertz

leftPosition = 0.85
rightPosition = 1.85
middlePosition = (rightPosition - leftPosition) / 2 + leftPosition

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

while continue_reading:
    #Get data from phone
    rawData = connection.recv(4)
    rollPitch = [ord(rawData[0]), ord(rawData[1])]

    #servo
    position = round(interp(rollPitch[1], [0,255], [leftPosition, rightPosition]))
    dutyCyclePercentage = position * 100 / msPerCycle
    pwm.start(dutyCyclePercentage)
    print position

    # Scan for cards
    (status,TagType) = MIFAREReader.MFRC522_Request(MIFAREReader.PICC_REQIDL)

    # Get the UID of the card
    (status,uid) = MIFAREReader.MFRC522_Anticoll()

    # If we have the UID, continue
    if status == MIFAREReader.MI_OK:
        print uid

