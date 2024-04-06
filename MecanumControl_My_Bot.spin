{
  Project: Mobile Platform - Build 2 (Motor Control)
  Platform: Parallax Project USB Board
  Revision: 1.3
  Author: Reginald
  Date: 7 Feb 2024
  Log:
    Date: 13 Nov 2023
          Enabled all motor and added movement pointer control from MyLiteKit to control
          from sensor control

    Date: 15 Nov 2023
          Added ready and msval pointers so that when CommControl is ready it will enable
          motor movement as well as control over motor control from outside object file.
          Enabled for usage with CommControl.spin

    Date: 17Nov 2023
          Added speed pointer to change speed from commcontrol instead

    Date: 24 Jan 2024
          Added controls for mecanum wheels

    Date: 7 Feb 2024
          Changed to serial mode communication for RoboClaw
}
speed   = 30
p_timer = 2000

CON
  'Clock Settings
  _clkmode = xtal1 + pll16x                                                     'Standard clock mode * crystal frequency = 80 MHz
  _xinfreq = 5_000_000
  _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
  _Ms_001 = _ConClkFreq / 1_000

VAR

  'long _Ms_001                 ' Time Delay
  long MotorCogID, MotorCogStack[64]
  long SPD                                                                      'Speed set ting from 0% to 100%

OBJ

  Term          : "FullDuplexSerialExt.spin"                                    'Pins 31, 30 for Rx, Tx - For Debugging, use Term.Dec(var) to check value of a variable
  Def           : "RxBoardDef.spin"
  SerialDriver  : "FDS4FC.spin"

PUB Main

  'Serial to PC
  'Term.Start(Def#D_Rx,Def#D_Tx,0,Def#D_Baudrate)
  'Pause(1000)
  ActMCTest
  'repeat

PUB ActMCTest 'Activate and initialise core for motor controls

  StopCore                                                                      'Prevent stacking drivers
  MotorCogID := cognew(StartMC, @MotorCogStack) + 1                             'Start new cog with Start method

  return MotorCogID                                                             'Return cogID for tracking

PUB StopCore 'Stop active cog
  if MotorCogID                                                                 'Check for active cog
    cogstop(MotorCogID~)                                                        'Stop the cog
  return MotorCogID

PUB StartMC | localSpd

  'Term.Start(31, 30, 0, 115200)
  SerialDriver.AddPort(0, Def#R1S2, Def#R1S1, SerialDriver#PINNOTUSED, SerialDriver#PINNOTUSED, SerialDriver#DEFAULTTHRESHOLD, %000000, Def#SSBaud)
  SerialDriver.AddPort(1, Def#R2S2, Def#R2S1, SerialDriver#PINNOTUSED, SerialDriver#PINNOTUSED, SerialDriver#DEFAULTTHRESHOLD, %000000, Def#SSBaud)
  SerialDriver.Start
  Pause(p_timer)
  SPD := speed                               'set for default speed % from MyLiteKit
  Pause(p_timer)
  TestMotor(SPD)

PUB TestMotor(val)

  StopMotors

  Digonal_DR(val)
  Pause(p_timer)
  StopMotors
  Pause(100)

  Digonal_DL(val)
  Pause(p_timer)
  StopMotors
    Pause(100)

PUB StopMotors | i 'Set all motors to zero point

  repeat i from 0 to 1                                                          'Cycle through all the motors
    SerialDriver.Tx(i, 0)                                                       'Set the motor to zero point in %
  return

PUB slowdown(DutyCycle): decreaser | dec, compValue

  compValue := (DutyCycle * 63)/100

  if !(compValue == dec)
    dec := dec+1

  decreaser := dec

PUB Forward(DutyCycle) | compValue

  DutyCycle := DutyCycle <#= 100
  DutyCycle := DutyCycle #>= 1
  compValue := (DutyCycle * 63)/100

  SerialDriver.Tx(0, 64  - compValue )   ' Front Left Wheel
  SerialDriver.Tx(0, 192 - compValue )   ' Front Right Wheel
  SerialDriver.Tx(1, 64  - compValue )   ' Back Left Wheel
  SerialDriver.Tx(1, 192 - compValue )   ' Back Right Wheel

  return

PUB Reverse(DutyCycle) | compValue

  DutyCycle := DutyCycle <#= 100
  DutyCycle := DutyCycle #>= 1
  compValue := (DutyCycle * 63)/100

  SerialDriver.Tx(0, 64  + compValue )
  SerialDriver.Tx(0, 192 + compValue )
  SerialDriver.Tx(1, 64  + compValue )
  SerialDriver.Tx(1, 192 + compValue )
  return

PUB TurnRight(DutyCycle) | compValue 'Set motors to turn left

  DutyCycle := DutyCycle <#= 100
  DutyCycle := DutyCycle #>= 1
  compValue := (DutyCycle * 63)/100

  SerialDriver.Tx(0, 64  + compValue )
  SerialDriver.Tx(0, 192 - compValue )
  SerialDriver.Tx(1, 64  + compValue )
  SerialDriver.Tx(1, 192 - compValue )
  return

PUB TurnLeft(DutyCycle) | compValue 'Set motors to turn right

  DutyCycle := DutyCycle <#= 100
  DutyCycle := DutyCycle #>= 1
  compValue := (DutyCycle * 63)/100

  SerialDriver.Tx(0, 64  - compValue )
  SerialDriver.Tx(0, 192 + compValue )
  SerialDriver.Tx(1, 64  - compValue )
  SerialDriver.Tx(1, 192 + compValue )
  return

PUB MoveRight(DutyCycle) | compValue 'Side left

  DutyCycle := DutyCycle <#= 100
  DutyCycle := DutyCycle #>= 1
  compValue := (DutyCycle * 63)/100

  SerialDriver.Tx(0, 64  + compValue )
  SerialDriver.Tx(0, 192 - compValue )
  SerialDriver.Tx(1, 64  - compValue )
  SerialDriver.Tx(1, 192 + compValue )
  return

PUB MoveLeft(DutyCycle) | compValue 'Side Right

  DutyCycle := DutyCycle <#= 100
  DutyCycle := DutyCycle #>= 1
  compValue := (DutyCycle * 63)/100

  SerialDriver.Tx(0, 64  - compValue )
  SerialDriver.Tx(0, 192 + compValue )
  SerialDriver.Tx(1, 64  + compValue )
  SerialDriver.Tx(1, 192 - compValue )
  return

PUB Digonal_UR(DutyCycle) | compValue 'Diagonally top right

  DutyCycle := DutyCycle <#= 100
  DutyCycle := DutyCycle #>= 1
  compValue := (DutyCycle * 63)/100

  SerialDriver.Tx(0, 64 )
  SerialDriver.Tx(0, 192 - compValue)
  SerialDriver.Tx(1, 64  - compValue )
  SerialDriver.Tx(1, 192 )
  return
PUB Digonal_UL(DutyCycle) | compValue 'Diagonally top left

  DutyCycle := DutyCycle <#= 100
  DutyCycle := DutyCycle #>= 1
  compValue := (DutyCycle * 63)/100

  SerialDriver.Tx(0, 64 - compValue )
  SerialDriver.Tx(0, 192 )
  SerialDriver.Tx(1, 64  )
  SerialDriver.Tx(1, 192 - compValue)
  return

PUB Digonal_DR(DutyCycle) | compValue 'Diagonally bottom right

  DutyCycle := DutyCycle <#= 100
  DutyCycle := DutyCycle #>= 1
  compValue := (DutyCycle * 63)/100

  SerialDriver.Tx(0, 64  + compValue )
  SerialDriver.Tx(0, 192  )
  SerialDriver.Tx(1, 64 )
  SerialDriver.Tx(1, 192 + compValue  )
  return

PUB Digonal_DL(DutyCycle) | compValue 'Diagonally bottom left

  DutyCycle := DutyCycle <#= 100
  DutyCycle := DutyCycle #>= 1
  compValue := (DutyCycle * 63)/100

  SerialDriver.Tx(0, 64  )
  SerialDriver.Tx(0, 192 + compValue)
  SerialDriver.Tx(1, 64  + compValue)
  SerialDriver.Tx(1, 192 )
  return

PUB ArkRight(DutyCycle) | compValue 'Right bend

  DutyCycle := DutyCycle <#= 100
  DutyCycle := DutyCycle #>= 1
  compValue := (DutyCycle * 63)/100

  SerialDriver.Tx(0, 64 - compValue )
  SerialDriver.Tx(0, 192  )
  SerialDriver.Tx(1, 64 - compValue )
  SerialDriver.Tx(1, 192  )
  return

PUB ArkLeft(DutyCycle) | compValue 'Left bend

  DutyCycle := DutyCycle <#= 100
  DutyCycle := DutyCycle #>= 1
  compValue := (DutyCycle * 63)/100

  SerialDriver.Tx(0, 64 )
  SerialDriver.Tx(0, 192 + compValue )
  SerialDriver.Tx(1, 64  )
  SerialDriver.Tx(1, 192 + compValue )
  return

PUB Pivot_Right_Front(DutyCycle) | compValue 'Right Rotation Front


  DutyCycle := DutyCycle <#= 100
  DutyCycle := DutyCycle #>= 1
  compValue := (DutyCycle * 63)/100

  SerialDriver.Tx(0, 64  + compValue )
  SerialDriver.Tx(0, 192 + compValue )
  SerialDriver.Tx(1, 64 )
  SerialDriver.Tx(1, 192 )
  return
PUB Pivot_Left_Front(DutyCycle) | compValue 'Left Rotation Front


  DutyCycle := DutyCycle <#= 100
  DutyCycle := DutyCycle #>= 1
  compValue := (DutyCycle * 63)/100

  SerialDriver.Tx(0, 64  - compValue )
  SerialDriver.Tx(0, 192 - compValue )
  SerialDriver.Tx(1, 64 )
  SerialDriver.Tx(1, 192 )
  return

PUB Pivot_Right_Rear(DutyCycle) | compValue 'Right Rotation  rear

  DutyCycle := DutyCycle <#= 100
  DutyCycle := DutyCycle #>= 1
  compValue := (DutyCycle * 63)/100

  SerialDriver.Tx(0, 64 )
  SerialDriver.Tx(0, 192 )
  SerialDriver.Tx(1, 64  - compValue )
  SerialDriver.Tx(1, 192 - compValue )
  return
PUB Pivot_Left_Rear(DutyCycle) | compValue 'Left Rotation  rear

  DutyCycle := DutyCycle <#= 100
  DutyCycle := DutyCycle #>= 1
  compValue := (DutyCycle * 63)/100

  SerialDriver.Tx(0, 64 )
  SerialDriver.Tx(0, 192 )
  SerialDriver.Tx(1, 64  + compValue )
  SerialDriver.Tx(1, 192 + compValue )
  return

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)
    waitcnt(t += _Ms_001)
  return