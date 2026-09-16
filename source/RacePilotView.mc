import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
using Toybox.WatchUi;
using Toybox.Graphics;

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
    protected var phaseDistances = [0.0, 3.0, 15.0, 18.0];

    // Class internal variables
    // --------------------------------------------------

    var targetPace = 0;  // Calcualted from race distance and target time
    var timer = 0;  // timerTime converted to SECONDS
    var distance = 0;  // elapsedDistance


    //* ------------- CORE FUNCTIONS ------------------

    // Set the label of the data field here.
    function initialize() {
        DataField.initialize();

        // Get device settings (LOW PRIORITY for the moment) - units, etc

        // Initialise user data from ConnectIQ
        initializeUserData();

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
            "SOME TEST",
            Graphics.TEXT_JUSTIFY_CENTER);



        // ****** BLOCKS FOR DISPLAY PROCESSING

        // Update time delta value and background colour

        // Update filtered pace value

        // Update HR value

        // Update race phase bar

    }


    // * ---------- Processing Functions ------------------

    function initializeUserData() as Void {
        // Get user data from ConnectIQ
    }

    function computeValues(info) as Void {
        // Compute all values based on current info
        // See Activity.Info in the documentation for available information.
        // return self.raceProfile.mRaceDistance;  // Return the

        // ****** BLOCKS FOR MAIN PROCESSING

        // Update `DistanceCorrector` with GPS distance

        // Get elapsed time
        // Get current HR

        // Calc current phase in `PhaseManager` based on corrected distance

        // Calculate current time delta in `TimeDeltaCalculator` based on corrected distance and elapsed time

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