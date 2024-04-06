{
  control robot via blooth zigbee
}
CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

'Define pins and BAUD rate
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  comRx = 20
  comTx = 21
  comBaud = 9600

'Define Commands
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  comStart     = $7A
  comForward   = $01
  comReverse   = $02
  comTurnLeft  = $03
  comTurnRight = $04
  comStopAll   = $AA

VAR
  long _Ms_001
  long CommCogID, CommCogStack[64]
  long dir, rdy

OBJ
  Comm  : "FullDuplexSerial.spin"                                          'UART Communication for control

PUB main
  Init(dir, rdy, 1000)

  repeat
PUB Init(DirPtr , RDYPtr, MsVal)                                           'Initialise Core for Communications

  _Ms_001 := MsVal                                                         'Sync time delays
  StopCore                                                                 'Prevent stacking drivers
  CommCogID := cognew(Start(DirPtr, RDYPtr), @CommCogStack)                                                                    'Initialise new cog with Start method

  return CommCogID

PUB Start(DirPtr, RDYPtr) | rxVal                                          'Looping code for Op-Code update

  'Set up new cog
  Comm.Start(comRx, comTx, 0, comBaud)                                     'Start new cog for UART Communication with ZigBee
  BYTE[RDYPtr]++                                                           'Update Ready Byte

  'Poll for commands
  repeat                                                                   'Protocol starts with start BYTE
    rxVal := Comm.Rx
    if rxVal == ComStart
      repeat
        rxVal := Comm.Rx                                                   'Retrieve direction BYTE
        case rxVal                                                         'Update direction using Op-Code
          comForward:
                  BYTE[DirPtr] := 1     'Comm.Str(String("Forward"))
          comReverse:
                  BYTE[DirPtr] := 2     'Comm.Str(String("Reverse"))
          comTurnLeft:
                  BYTE[DirPtr] := 3     'Comm.Str(String("Left"))
          comTurnRight:
                  BYTE[DirPtr] := 4     'Comm.Str(String("Right"))
          comStopAll:
                  BYTE[DirPtr] := 5     'Comm.Str(String("Stop"))

PUB StopCore                                                               'Stop active cog
  if CommCogID                                                             'Check for active cog
    cogStop(CommCogID~)                                                    'Stop the cog and zero out ID
  return CommCogID

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)
    waitcnt(t += _Ms_001)
  return