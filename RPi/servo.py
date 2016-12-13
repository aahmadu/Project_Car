import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BOARD)
GPIO.setup(11, GPIO.OUT)

frequencyHertz=50
pwm = GPIO.PWM(11,frequencyHertz)

leftPosition = 0.75
rightPosition = 2
middlePosition = (rightPosition - leftPosition) / 2 + leftPosition

positionList = [leftPosition, middlePosition, rightPosition, middlePosition]

msPerCycle = 1000/frequencyHertz

for i in range(1):
  for position in positionList:
    dutyCyclePercentage = position * 100 / msPerCycle
    pwm.start(dutyCyclePercentage)
    time.sleep(5)

pwm.stop()
GPIO.cleanup()
