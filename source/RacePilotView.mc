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
        raceProfile = new RaceProfile();
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) {
        // See Activity.Info in the documentation for available information.
        // return self.raceProfile.mRaceDistance;  // Return the
         displayValue = self.raceProfile.mRaceDistance;  // Return the race
    }

    function onUpdate(dc as Graphics.Dc) as Void{
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_MEDIUM,
            displayValue as String,
            Graphics.TEXT_JUSTIFY_CENTER);

    }

}