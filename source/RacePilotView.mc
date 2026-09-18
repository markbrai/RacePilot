import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

class RacePilotView extends WatchUi.DataField {

    // Variables from ConnectIQ (ALL HARDCODED FOR NOW)
    // -------------------------------------------------
    // Total race distance
    protected var raceDistance = 21.0975;
    // Target time in MINUTES
    // TODO: Add function to convert string of hh:mm:ss to seconds
    protected var targetTime = 104.0;
    // Gel frequency in MINUTES
    protected var gelFrequency = 25.0;
    // Time offset for first gel
    protected var gelOffset = 30.0;
    // Phase distances
    // TODO: Add function to take semi-colon separated string and convert to array of floats
    protected var phaseDistances = [0.0, 3.0, 15.0, 18.0] as Array<Float>;
    // Controlled start pace delta (SECONDS/km)
    protected var controlledStartDelta = 5.0;

    // Class internal variables
    // --------------------------------------------------

    var targetPace = 0;  // Calcualted from race distance and target time
    var phasePaces = new Array<Float>[4];
    const TABLE_STEP = 0.05;  // km - every 50 metres
    var expectedTimeTable = [] as Array<Float>;  // Expected time table for each distance step
    var timer = 0;  // timerTime converted to SECONDS
    var distance = 0;  // elapsedDistance
    var prevDistance = 0; // previous elapsedDistance
    var correctedDistance = 0; // corrected elapsedDistance
    var phase = 0; // Current race phase (0-4)
    var timeDelta = 0;
    var goalDelta = 0;



    //* ------------- CORE FUNCTIONS ------------------

    // Set the label of the data field here.
    function initialize() {
        DataField.initialize();

        // Get device settings (LOW PRIORITY for the moment) - units, etc

        // Initialise user data from ConnectIQ
        initializeUserData();

        // Calculate target pace and phase paces
        targetPace = calcTargetPace();
        phasePaces = calcPhasePaces(targetPace);
        expectedTimeTable = buildExpectedTimeTable();

        System.println(getExpectedTime(15.1));

    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) {
        
        // Convert timer from milliseconds to seconds
        if (info.timerTime != null)
        {
            timer = info.timerTime / 1000; 
        }

        // Allows metric/imperial conversion in future if needed
        if (info.elapsedDistance != null)
        {
            distance = info.elapsedDistance;
            updateDistance(distance);
        }

        computeValues(info);

        

    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.  
    function onUpdate(dc as Graphics.Dc) as Void{
        
        dc.clear();
        var width = dc.getWidth();
        var height = dc.getHeight();

        var primaryBackgroundColor = Graphics.COLOR_BLACK;
        var primaryForegroundColor = Graphics.COLOR_WHITE;

        // Set overall black (or white) background
        dc.setColor(primaryBackgroundColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0,0, width, height);


        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(width/2, height/2,50);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height / 2,
            Graphics.FONT_MEDIUM,
            "Some Text",
            Graphics.TEXT_JUSTIFY_CENTER);



        // ****** BLOCKS FOR DISPLAY PROCESSING

        // Update time delta value and background colour

        // Update filtered pace value

        // Update HR value

        // Update race phase bar

    }


    // * ---------- Initialisation Functions ------------------

    function initializeUserData() as Void {
        // Get user data from ConnectIQ
    }

    // * ---------- RaceProfile Functions ------------------

    function calcTargetPace() as Float {
        /* 
        Takes target time (in minutes) and race distance to 
        calculate an overall race target pace
        */

        targetPace = (self.targetTime * 60) / self.raceDistance ;  // SECONDS per km

        return targetPace;

    }

    function calcPhasePaces(targetPace as Float) as Array<Float> {
        // Calculate target pace for each phase based on race
        var phasePaces = [targetPace, targetPace, targetPace, targetPace] as Array<Float>;

        var controlledStartDistance = phaseDistances[1];  // Assuming the second phase is the controlled start
        var startToPushDistance = raceDistance - phaseDistances[2];  // Assuming the third phase is the start to push

        // Calculate time 'lost' in controlled start if running at target pace - controlledStartDelta
        var controlledStartLostTime = controlledStartDistance * controlledStartDelta;  // in seconds

        // Calculate the pace adjustment in 'Start to Push' to make up controlledStartLostTime
        var startToPushPaceIncrease = controlledStartLostTime / startToPushDistance;  // in s/km

        var controlledStartPace = targetPace + controlledStartDelta;  // slower pace for controlled start
        var startToPushPace = targetPace - startToPushPaceIncrease;

        phasePaces[0] = controlledStartPace;
        phasePaces[1] = targetPace;  // Main race phase
        phasePaces[2] = startToPushPace;
        phasePaces[3] = startToPushPace;  // Assuming the last phase is the same as 'Start to Push'

        return phasePaces;

    }

    function getTargetPace(distance) as Float {
        for (var i = 0; i < phasePaces.size(); i++) {
            // At start of race, return 0
            if (correctedDistance == 0 || correctedDistance == null) {
                return phasePaces[0];
            }
            // Else return current phase
            if (correctedDistance < phaseDistances[i]) {
                return phasePaces[i];
            }
        }
        return phasePaces[3];  // If beyond last phase, return size
    }

    function buildExpectedTimeTable() as Array<Float>{

        var expectedTimeTable = [] as Array<Float>;

        var cumulativeTime = 0.0;
        var _distance = 0.0;

        expectedTimeTable.add(0.0);

        // Build the table at TABLE_STEP increments until the race distance is reached
        while(_distance < raceDistance) {

            // use midpoint of segment for better accuracy
            var pace = getTargetPace(_distance + TABLE_STEP / 2);
            cumulativeTime += pace * TABLE_STEP;  // pace is in seconds per km, TABLE_STEP is in km, so cumulativeTime is in seconds
            expectedTimeTable.add(cumulativeTime);
            _distance += TABLE_STEP;
        }

        return expectedTimeTable;
    }

    // * ---------- DistanceCorrector Functions ------------------

    function updateDistance(newElapsedDistance as Float or Null) as Void {
        // Update the corrected distance based on new elapsed distance
        
        // Update the previous elapsed distance
        prevDistance = distance;

        // Update the current elapsed distance
        distance = newElapsedDistance;

        // Calculate the delta distance
        var deltaDistance = distance - prevDistance;

        // Update the correct distance based on the delta distance
        correctedDistance += deltaDistance;
    }


    // * ---------- PhaseManager Functions ------------------

    function whichPhase(correctedDistance as Float) as Integer {
        // Determine which phase the runner is currently in based on distance
        /*
        Phase 0: 0 to phaseDistances[0] - Race Start
        Phase 1: phaseDistances[0] to phaseDistances[1] - Controlled Start
        Phase 2: phaseDistances[1] to phaseDistances[2] - Main Race
        Phase 3: phaseDistances[2] to phaseDistances[3] - Start to Push
        Phase 4: phaseDistances[3] to race - Empty the Bucket
        */
        for (var i = 0; i < phaseDistances.size(); i++) {
            // At start of race, return 0
            if (correctedDistance == 0 || correctedDistance == null) {
                return 0;
            }
            // Else return current phase
            if (correctedDistance < phaseDistances[i]) {
                return i;
            }
        }
        return phaseDistances.size();  // If beyond last phase, return size
    }


    // * ---------- TimeDeltaCalculator Functions ------------------

    function calcPlanDelta(correctedDistance as Float, elapsedTime as Float) as Float {
        // * Based on PLAN paces --> This is the value shown to the runner
        // Calculate the time delta based on corrected distance and elapsed time
        // Time delta is the difference between expected time and actual time

        var expectedTime = getExpectedTime(correctedDistance);

        return elapsedTime - expectedTime;
    }

    function calcGoalDelta(correctedDistance as Float, elapsedTime as Float) as Float {
        // * Based on Goal pace (distance / time) --> For internal use only
        // Calculate the time delta based on corrected distance and elapsed time
        // Time delta is the difference between expected time and actual time

        var expectedTime = targetPace * correctedDistance; 
        
        return elapsedTime - expectedTime;  
    }

    function getExpectedTime(corrDistance as Float) as Float {
        // Interpolates the expected time from the lookup table

        if (corrDistance <= 0.0) {
            return 0.0;
        }

        if (corrDistance >= raceDistance) {
            return expectedTimeTable[expectedTimeTable.size() - 1];
        }

        var indexFloat = corrDistance / TABLE_STEP;

        var lowerIndex = indexFloat.toNumber().toLong().toNumber();

        var fraction = indexFloat - lowerIndex;

        var lowerTime = expectedTimeTable[lowerIndex];
        var upperTime = expectedTimeTable[lowerIndex + 1];

        return lowerTime + ((upperTime - lowerTime) * fraction);
    }



    // * ---------- PaceEngine Functions ------------------


    // * ---------- GuidanceEngine Functions ------------------


    // * ---------- AlertManager Functions ------------------



    function computeValues(info) as Void {
        // Compute all values based on current info
        // See Activity.Info in the documentation for available information.
        // return self.raceProfile.mRaceDistance;  // Return the

        // ****** BLOCKS FOR MAIN PROCESSING

        // Calc current phase in `PhaseManager` based on corrected distance
        phase = whichPhase(correctedDistance);

        // Calculate current time delta in `TimeDeltaCalculator` based on corrected distance and elapsed time
        // This value is displayed to the user
        timeDelta = calcPlanDelta(correctedDistance, timer);
        goalDelta = calcGoalDelta(correctedDistance, timer);

        // Calculate equivalent average pace in `PaceEngine` based on corrected distance and time delta

        // Calculate filtered current pace in `PaceEngine` based on GPS distance and elapsed time

        // Calculate pace offset in `PaceEngine` based on target pace, equiv avg pace, and filtered current pace

        // Calculate maximum sustainable pace in `PaceEngine` based on aggression settings and target pace

        // Calculate envelope colour in PaceEngine

        // PLACEHOLDER FOR GUIDANCE ENGINE

        // Update `RaceState`

        // Call `AlertEngine` to check for any alerts based on current state
    }

}