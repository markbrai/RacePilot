import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class DistanceCorrector {

    var prevElapsedDistance;
    var elapsedDistance;
    var deltaDistance;
    var correctedDistance;
    

    function initialize() {
        // Initialization code for RaceState can go here.

        // Initialise distances to 0
        self.elapsedDistance = 0.0;
        self.correctedDistance = 0.0;
        self.prevElapsedDistance = 0.0;
        self.deltaDistance = 0.0;

    }


    function updateDistances(newElapsedDistance as Float or Null) {

        // Update the previous elapsed distance
        self.prevElapsedDistance = self.elapsedDistance;

        // Update the current elapsed distance
        self.elapsedDistance = newElapsedDistance;

        // Calculate the delta distance
        self.deltaDistance = self.elapsedDistance - self.prevElapsedDistance;

        // Update the corrected distance based on the delta distance
        self.correctedDistance += self.deltaDistance;

    }

}