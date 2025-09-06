using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Communications as Comm;
using Toybox.Lang as Lang;
using Toybox.Json as Json;
using Toybox.Application as App; // pour Storage

class ETHPriceView extends Ui.View {
    var _priceStr = "--";
    var _lastUpdated = "--";

    function onShow() {
        // Récupère valeur cachée si dispo
        var cached = App.getApp().getProperty("lastPrice");
        if (cached != null) {
            _priceStr = cached;
        }
        fetchPrice();
    }

    function onUpdate(dc as Gfx.Dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.clear();
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

        dc.drawText(w/2, h*0.30, Gfx.FONT_XLARGE, "ETH", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(w/2, h*0.55, Gfx.FONT_LARGE, _priceStr + " €", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(w/2, h*0.80, Gfx.FONT_SMALL, "Maj: " + _lastUpdated, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function fetchPrice() {
        var url = "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=eur";
        var params = { :method => "GET" };

        try {
            Comm.makeWebRequest(url, params, method(:onResponse));
        } catch(e) {
            Sys.println("HTTP error: " + e);
        }
    }

    function onResponse(statusCode as Number, data as Dictionary or String) as Void {
        if (statusCode == 200) {
            try {
                var body = (data instanceof Dictionary) ? data : Json.fromJson(data);
                var eur = body["ethereum"]["eur"];
                _priceStr = Lang.format("%.2f", [eur]);
                App.getApp().setProperty("lastPrice", _priceStr);
                _lastUpdated = Sys.getClockTime().toString();
            } catch(e) {
                _priceStr = "Err JSON";
            }
        } else {
            _priceStr = "HTTP " + statusCode;
        }
        Ui.requestUpdate();
    }

    function onHide() { }
}
