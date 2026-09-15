import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
using Toybox.WatchUi;
using Toybox.Graphics;

class RacePilotView extends WatchUi.DataField {

    protected var raceProfile;
    protected var displayValue; 

    // Set the label of the data field here.
    function initialize() {
        DataField.initialize();
        // Initialize the race profile object
        raceProfile = new RaceProfile();

        // Initialize the RaceState object

        // Initialize the PaceEngine object

        // Initialize the PhaseManager object

        // Initialize the DistanceCorrector object

        // Initialize the TimeDeltaCalculator object

        // Initialize the GuidanceEngine object

        // Initialize the AlertEngine object
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) {
        // See Activity.Info in the documentation for available information.
        // return self.raceProfile.mRaceDistance;  // Return the
         displayValue = raceProfile.mRaceDistance;  // Return the race

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
            displayValue as String,
            Graphics.TEXT_JUSTIFY_CENTER);



        // ****** BLOCKS FOR DISPLAY PROCESSING

        // Update time delta value and background colour

        // Update filtered pace value

        // Update HR value

        // Update race phase bar

    }

}