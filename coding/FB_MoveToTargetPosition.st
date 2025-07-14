FUNCTION_BLOCK FB_MoveToTargetPosition
VAR_INPUT
    PositionID  : INT;
    TargetX     : INT;
    TargetY     : INT;
    TargetZ     : INT;
    Velocity    : REAL;
END_VAR

VAR_OUTPUT
    IsPositionReached : BOOL;
END_VAR

VAR
    Current_X : INT;
    Current_Y : INT;
    Current_Z : INT;
END_VAR

robomove.Velocity := Velocity;
GVL.g_robot.PosMem.dwCurrentID := PositionID;
GVL.g_robot.xGotoSelectedPos := TRUE;

Current_X := LREAL_TO_INT(GVL.g_robotState.grap_MCS.Position.c.X);
Current_Y := LREAL_TO_INT(GVL.g_robotState.grap_MCS.Position.c.Y);
Current_Z := LREAL_TO_INT(GVL.g_robotState.grap_MCS.Position.c.Z);

IF (Current_X = TargetX) AND (Current_Y = TargetY) AND (Current_Z = TargetZ) THEN
    IsPositionReached := TRUE;
    GVL.g_robot.xGotoSelectedPos := FALSE;
ELSE
    IsPositionReached := FALSE;
END_IF
