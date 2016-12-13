import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BOARD)
GPIO.setup(11, GPIO.OUT)

frequencyHertz=50
pwm = GPIO.PWM(11,frequencyHertz)

msPerCycle = 1000/frequencyHertz

for i in range(3):
  position = float(raw_input("enter pn: "))
  dutyCyclePercentage = position * 100 / msPerCycle
  pwm.start(dutyCyclePercentage)

pwm.stop()
GPIO.cleanup()
