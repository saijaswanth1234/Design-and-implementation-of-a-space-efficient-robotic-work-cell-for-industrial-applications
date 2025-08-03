PROGRAM Example_Pick_EGP
VAR
    MoveToPosition: FB_MoveToTargetPosition;
    Current_X, Current_Y, Current_Z: LREAL;
    MachineState: UINT := 0;
    Phase: INT := 0;

    InitTimer, Timer1, Timer2, Timer3, Timer4: TON;
    start: BOOL;
    TimerState, TimerState1, TimerState2: BOOL;

    Conveyor AT %QX48.3: BOOL;
    Sensor_I3 AT %IX48.3: BOOL;
    EGP_Open AT %QX48.2: BOOL;
    EGP_Close AT %QX48.1: BOOL;
    IS_Gripper_Open AT %IX48.5: BOOL;

    Velocity: LREAL;
    WorkpieceIndex: INT := 0;
END_VAR

VAR
    WorkpiecePositions: ARRAY[0..5] OF ST_WorkpiecePlacement := [
        (ApproachPosID := 50, PlacePosID := 34, ApproachX := -337, ApproachY := -729, ApproachZ := 215, PlaceX := -337, PlaceY := -770, PlaceZ := 212),
        (ApproachPosID := 51, PlacePosID := 33, ApproachX := -337, ApproachY := -720, ApproachZ := 252, PlaceX := -337, PlaceY := -768, PlaceZ := 247),
        (ApproachPosID := 52, PlacePosID := 32, ApproachX := -337, ApproachY := -720, ApproachZ := 288, PlaceX := -337, PlaceY := -768, PlaceZ := 285),
        (ApproachPosID := 53, PlacePosID := 31, ApproachX := -337, ApproachY := -720, ApproachZ := 322, PlaceX := -337, PlaceY := -768, PlaceZ := 322),
        (ApproachPosID := 54, PlacePosID := 30, ApproachX := -338, ApproachY := -720, ApproachZ := 358, PlaceX := -339, PlaceY := -770, PlaceZ := 358),
        (ApproachPosID := 55, PlacePosID := 29, ApproachX := -339, ApproachY := -720, ApproachZ := 395, PlaceX := -340, PlaceY := -765, PlaceZ := 396)
    ];
END_VAR

// Update robot current coordinates
Current_X := LREAL_TO_INT(gvl.g_robotState.grap_MCS.Position.c.X);
Current_Y := LREAL_TO_INT(gvl.g_robotState.grap_MCS.Position.c.Y);
Current_Z := LREAL_TO_INT(gvl.g_robotState.grap_MCS.Position.c.Z);

// Delay at program startup
IF InitTimer.Q = FALSE THEN
    InitTimer(IN := TRUE, PT := T#1S);
ELSE
    IF MachineState <> 0 THEN
        IF Sensor_I3 OR GVL.g_robotState.xEmergencyStop OR NOT GVL.g_robotState.xAllAxesEnabled OR GVL.g_robotState.xAxisInError OR MachineState = 30 THEN
            Conveyor := FALSE;
        ELSE
            Conveyor := TRUE;
        END_IF
    END_IF

    CASE MachineState OF
        0:
            IF NOT GVL.g_robot.xToggleEnableAll AND NOT GVL.g_robotState.xEmergencyStop THEN
                IF GVL.g_robotState.xAxisInError THEN
                    GVL.g_robot.xReset := TRUE;
                    GVL.g_robot.xToggleEnableAll := TRUE;
                END_IF
                GVL.g_robot.xToggleEnableAll := TRUE;
                IF NOT GVL.g_robotState.xAxisInError AND GVL.g_robot.xToggleEnableAll THEN
                    MachineState := 10;
                END_IF
            END_IF

        10:
            MoveToPosition(PositionID := 15, TargetX := 583, TargetY := -189, TargetZ := 216, Velocity := 60);
            IF MoveToPosition.IsPositionReached THEN
                IF NOT IS_Gripper_Open THEN
                    EGP_Open := TRUE;
                    EGP_Close := FALSE;
                END_IF
                MachineState := 20;
            END_IF

        20:
            CASE Phase OF
                0:
                    IF Sensor_I3 THEN Phase := 1; END_IF
                1:
                    MoveToPosition(PositionID := 16, TargetX := 582, TargetY := -191, TargetZ := 164, Velocity := 10);
                    IF MoveToPosition.IsPositionReached THEN
                        IF IS_Gripper_Open THEN
                            EGP_Open := FALSE;
                            EGP_Close := TRUE;
                        END_IF
                        Phase := 2;
                    END_IF
                2:
                    IF Timer1.Q = FALSE THEN Timer1(IN := TRUE, PT := T#0.5S, Q => start); END_IF
                    IF start THEN
                        Timer1(IN := FALSE, Q => TimerState);
                        IF Timer1.Q = FALSE THEN
                            MachineState := 30;
                            Phase := 0;
                            start := FALSE;
                        END_IF
                    END_IF
            END_CASE

        30:
            MoveToPosition(PositionID := 15, TargetX := 583, TargetY := -189, TargetZ := 216, Velocity := 20);
            IF MoveToPosition.IsPositionReached THEN MachineState := 40; END_IF

        40:
            MoveToPosition(PositionID := 17, TargetX := -49, TargetY := -395, TargetZ := 336, Velocity := 35);
            IF MoveToPosition.IsPositionReached THEN MachineState := 50; END_IF

        50:
            MoveToPosition(PositionID := 18, TargetX := -41, TargetY := -405, TargetZ := 91, Velocity := 20);
            IF Timer2.Q = FALSE THEN Timer2(IN := TRUE, PT := T#0.5S, Q => start); END_IF
            IF start AND MoveToPosition.IsPositionReached THEN
                IF NOT IS_Gripper_Open THEN
                    EGP_Close := FALSE;
                    EGP_Open := TRUE;
                END_IF
                Timer2(IN := FALSE, Q => TimerState1);
                IF Timer2.Q = FALSE THEN
                    MachineState := 60;
                    start := FALSE;
                END_IF
            END_IF

        // State 60: Move back to position ID 17 
        60:
            MoveToPosition(
                PositionID 	:= 19,
                TargetX 	:= -41,
                TargetY 	:= -405,
                TargetZ 	:= 114,
				Velocity 	:= 10,
            );
            // Wait until the position is reached
            IF MoveToPosition.IsPositionReached THEN
                MachineState := 61; // Transition to state 70
            END_IF
		61:
            MoveToPosition(
                PositionID 	:= 20,
                TargetX 	:= 15,
                TargetY 	:= -405,
                TargetZ 	:= 110,
				Velocity 	:= 10,
            );
            // Wait until the position is reached
            IF MoveToPosition.IsPositionReached THEN
                MachineState := 62; // Transition to state 70
            END_IF
			62:
            MoveToPosition(
                PositionID 	:= 21,
                TargetX 	:= 4,
                TargetY 	:= -405,
                TargetZ 	:= 64,
				Velocity 	:= 10,
            );
            // Wait until the position is reached
            IF MoveToPosition.IsPositionReached THEN
                MachineState := 63; // Transition to state 70
            END_IF
			63:
            MoveToPosition(
                PositionID 	:= 22,
                TargetX 	:= -18,
                TargetY 	:= -405,
                TargetZ 	:= 64,
				Velocity 	:= 10,
            );
            // Wait until the position is reached
            IF MoveToPosition.IsPositionReached THEN
                MachineState := 64; // Transition to state 70
            END_IF
			64:
            MoveToPosition(
                PositionID 	:= 21,
                TargetX 	:= 4,
                TargetY 	:= -405,
                TargetZ 	:= 64,
				Velocity 	:= 10,
            );
            // Wait until the position is reached
            IF MoveToPosition.IsPositionReached THEN
                MachineState := 65; // Transition to state 70
            END_IF
			65:
            MoveToPosition(
                PositionID 	:= 20,
                TargetX 	:= 4,
                TargetY 	:= -405,
                TargetZ 	:= 110,
				Velocity 	:= 10,
            );
            // Wait until the position is reached
            IF MoveToPosition.IsPositionReached THEN
                MachineState := 66; // Transition to state 70
            END_IF
			66:
            MoveToPosition(
                PositionID 	:= 23,
                TargetX 	:= -33,
                TargetY 	:= -347,
                TargetZ 	:= 106,
				Velocity 	:= 10,
            );
            // Wait until the position is reached
            IF MoveToPosition.IsPositionReached THEN
                MachineState := 67; // Transition to state 70
            END_IF
			67:
            MoveToPosition(
                PositionID 	:= 24,
                TargetX 	:= -32,
                TargetY 	:= -347,
                TargetZ 	:= 73,
				Velocity 	:= 10,
            );
            // Wait until the position is reached
            IF MoveToPosition.IsPositionReached THEN
                MachineState := 68; // Transition to state 70
            END_IF
			68://pushing in y axis
            MoveToPosition(
                PositionID 	:= 25,
                TargetX 	:= -32,
                TargetY 	:= -386,
                TargetZ 	:= 73,
				Velocity 	:= 10,
            );
            // Wait until the position is reached
            IF MoveToPosition.IsPositionReached THEN
                MachineState := 69; // Transition to state 70
            END_IF
			69:
            MoveToPosition(
                PositionID 	:= 24,
                TargetX 	:= -32,
                TargetY 	:= -347,
                TargetZ 	:= 73,
				Velocity 	:= 10,
            );
            // Wait until the position is reached
            IF MoveToPosition.IsPositionReached THEN
                MachineState := 70; // Transition to state 70
            END_IF
			70:
            MoveToPosition(
                PositionID 	:= 23,
                TargetX 	:= -33,
                TargetY 	:= -347,
                TargetZ 	:= 106,
				Velocity 	:= 8,
            );
            // Wait until the position is reached
            IF MoveToPosition.IsPositionReached THEN
                MachineState := 71; // Transition to state 70
            END_IF
			71:
            MoveToPosition(
                PositionID 	:= 26,
                TargetX 	:= -55,
                TargetY 	:= -417,
                TargetZ 	:= 106,
				Velocity 	:= 8,
            );
            // Wait until the position is reached
            IF MoveToPosition.IsPositionReached THEN
                MachineState := 72; // Transition to state 72
            END_IF
			72:
            MoveToPosition(
                PositionID 	:= 27,
                TargetX 	:= -57,
                TargetY 	:= -418,
                TargetZ 	:= 83,
				Velocity 	:= 8,
            );
			IF Timer3.Q = FALSE THEN				
                Timer3(IN := TRUE, PT := T#1S, Q => start);
            END_IF
            // Wait for the timer to finish and the position to be reached
            IF start AND MoveToPosition.IsPositionReached THEN
						IF IS_Gripper_Open THEN
							EGP_Close:= TRUE;
							EGP_Open:= FALSE;
						END_IF		
                Timer3(IN := FALSE, Q => TimerState2); // Stop the timer
                IF Timer3.Q = FALSE THEN
                    MachineState := 73; // Transition to state 60
                    start := FALSE;    // Reset the start flag
                END_IF
            END_IF
			73:
            MoveToPosition(
                PositionID 	:= 14,
                TargetX 	:= -57,
                TargetY 	:= -413,
                TargetZ 	:= 136,
				Velocity 	:= 10,
            );
            // Wait until the position is reached
            IF MoveToPosition.IsPositionReached THEN
                MachineState := 74; // Transition to state 70
            END_IF
			
			74:
            MoveToPosition(
                PositionID := WorkpiecePositions[WorkpieceIndex].ApproachPosID,
                TargetX := WorkpiecePositions[WorkpieceIndex].ApproachX,
                TargetY := WorkpiecePositions[WorkpieceIndex].ApproachY,
                TargetZ := WorkpiecePositions[WorkpieceIndex].ApproachZ,
                Velocity := 20);
            IF MoveToPosition.IsPositionReached THEN
                MachineState := 75;
            END_IF

        75:
            MoveToPosition(
                PositionID := WorkpiecePositions[WorkpieceIndex].PlacePosID,
                TargetX := WorkpiecePositions[WorkpieceIndex].PlaceX,
                TargetY := WorkpiecePositions[WorkpieceIndex].PlaceY,
                TargetZ := WorkpiecePositions[WorkpieceIndex].PlaceZ,
                Velocity := 2);
            IF Timer4.Q = FALSE THEN
                Timer4(IN := TRUE, PT := T#0.5S, Q => start);
            END_IF
            IF start AND MoveToPosition.IsPositionReached THEN
                IF NOT IS_Gripper_Open THEN
                    EGP_Close := FALSE;
                    EGP_Open := TRUE;
                END_IF
                Timer4(IN := FALSE, Q => TimerState1);
                IF Timer4.Q = FALSE THEN
                    MachineState := 76;
                    start := FALSE;
                END_IF
            END_IF

        76:
            MoveToPosition(
                PositionID := WorkpiecePositions[WorkpieceIndex].ApproachPosID,
                TargetX := WorkpiecePositions[WorkpieceIndex].ApproachX,
                TargetY := WorkpiecePositions[WorkpieceIndex].ApproachY,
                TargetZ := WorkpiecePositions[WorkpieceIndex].ApproachZ,
                Velocity := 7);
            IF MoveToPosition.IsPositionReached THEN
                MachineState := 77;
            END_IF

        77:
            MoveToPosition(
                PositionID := 1,
                TargetX := -49,
                TargetY := -288,
                TargetZ := 381,
                Velocity := 30);
            IF MoveToPosition.IsPositionReached THEN
                WorkpieceIndex := WorkpieceIndex + 1;
                IF WorkpieceIndex <= 5 THEN
                    MachineState := 10;
                ELSE
                    MachineState := 100;
                END_IF
            END_IF
            
    END_CASE
END_IF
