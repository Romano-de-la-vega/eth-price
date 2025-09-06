using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class ETHPriceWidgetApp extends App.AppBase {

    function initialize() {
        App.AppBase.initialize();
    }

    function onStart(state) { }

    function onStop(state) { }

    function getInitialView() {
        return [ new ETHPriceView() ];
    }
}
