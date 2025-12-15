import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class Bold0App extends Application.AppBase {
    
    var mView;
    
    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() {
        mView = new Bold0View();
		onSettingsChanged();
        var delegate = new Bold0Delegate(mView);
		return [mView, delegate];
    }

    function onSettingsChanged() as Void {
        mView.onSettingsChanged();
        WatchUi.requestUpdate();
    }

}

function getApp() as Bold0App {
    return Application.getApp() as Bold0App;
}