import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class RaceProfile {

    // Race Distance in km
    var mRaceDistance = 21.0975;   // Default to HM
    // Target race time in seconds
    var mTargetTime = 6240.0;   // Defaul to 01:44:00
    // Gel freqency in seconds 
    var mGelFrequency = 1500.0;  // Every 25mins
    // First gel time 
    var mGelFirstTime = 1800.0;  // Start 30mins in
    // Array of phase start distances [Controlled start = 0, Main Race, Start to Push, Empty the Tanl]
    var mArrPhaseDistances = [0.0, 3.0, 15.0, 18.0];
    var mArrHrTargets = [151, 155, 165, 180];
    var mAggressionLevel = 1;

    function initialize() {
        // Initialization code for RaceProfile can go here.

        // TODO: Add in init of variables from Properties

    }
    
}