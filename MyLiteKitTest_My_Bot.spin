{
  ***************************************
  Mobile Platform - Build 2 (Sensor Test)
  ***************************************

  Main Modules (Track 7):
  1. Platform Chassis X 1
  2. Roboclaw Motor Controllers X 2
  3. Power Regulator Board X 1
  4. Rechargable Batteries X 3
  5. Propeller Project Board USB X 1
  6. HC-SR04 X 1
  7. VL6180X X 1
  8. Driver: Servo32V9.spin, UltrasonicSensor.spin, ToFSensor.spin, i2cDriver.spin

  Revision: 1.0
  Author: SIT
  Date: 1st Nov 2023
  Log:
    Date: Desc
}
CON
  _clkmode = xtal1 + pll16x                                       'Standard clock mode * crystal frequency = 80 MHz
  _xinfreq = 5_000_000
  _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
  _Ms_001 = _ConClkFreq / 1_000

VAR
  long  MCID, SCID, CCID                                          'cogID for tracking
  long  DIR,RDY                                                   'Stop flag

OBJ
  'Sensor        : "SensorControl_My_Bot.spin"                      'Ultrasonic and ToF Sensors
  Motor         : "MecanumControl_My_Bot.spin"                     'RoboClaw Controller
  Comm          : "CommControl_My_Bot.spin"
  'Term          : "FullDuplexSerial.spin"                          'Pins 31, 30 for Rx, Tx - For Debugging, use Term.Dec(var) to check value of a variable

PUB Main
 'Declaration & Initialisation
  'Term.Start(31, 30, 0, 115200)
  Pause(2000)
  'SCID := Sensor.ActSC(@DIR)                               'Initialise Sensor Driver
  MCID := Motor.ActMC(@DIR)
  CCID := Comm.Init(@DIR, @RDY, _Ms_001)                    'Initialise Motor Driver
  'Pause(100)
  'repeat while DIR < 5                                     'Wait until obstacle detected      (Stop == False)
  'Motor.StopCore                                                 'Disengage Motor cog
  'Motor.StopAllMotors                                            'Ensure all motor stopped
  repeat

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)
    waitcnt(t += _Ms_001)
  return