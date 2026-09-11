import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class RacePilotApp extends Application.AppBase {

    protected var racePilotView;

    function initialize() {
        AppBase.initialize();
        racePilotView = new RacePilotView();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView()
    {
        return [ racePilotView ];
    }

}

function getApp() as RacePilotApp {
    return Application.getApp() as RacePilotApp;
}