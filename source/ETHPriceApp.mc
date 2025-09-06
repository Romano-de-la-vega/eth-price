using Toybox.Application;
using Toybox.WatchUi;

class ETHPriceApp extends Application.App {
    function initialize() { App.initialize(); }
    function onStart(state) { }
    function onStop(state) { }
    function getInitialView() { return [ new ETHPriceView() ]; }
}
