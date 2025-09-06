using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Communications as Comm;
using Toybox.Lang as Lang;
using Toybox.Application as App;

class ETHPriceView extends Ui.View {

    var _priceStr as Lang.String = "--";
    var _lastUpdated as Lang.String = "--";

    function initialize() {
        Ui.View.initialize();
    }

    function onShow() {
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

    dc.drawText(w/2, (h*30)/100, Gfx.FONT_MEDIUM, "ETH", Gfx.TEXT_JUSTIFY_CENTER);
    dc.drawText(w/2, (h*55)/100, Gfx.FONT_LARGE, _priceStr + " €", Gfx.TEXT_JUSTIFY_CENTER);
    dc.drawText(w/2, (h*80)/100, Gfx.FONT_SMALL, "Maj: " + _lastUpdated, Gfx.TEXT_JUSTIFY_CENTER);
}



    function fetchPrice() {
        var url = "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=eur";
        var params = { :method => "GET" };

        try {
            Comm.makeWebRequest(url, params, method(:onResponse));
        } catch(e) {
            Sys.println("HTTP error: " + e);
            _priceStr = "ERR";
            Ui.requestUpdate();
        }
    }

    // No Json: parse "eur" from responseContent manually
    function onResponse(statusCode as Lang.Number, data) as Void {
        if (statusCode == 200 && data != null) {
            var text = null;

            // Get response body as string
            if (data instanceof Lang.Dictionary && data.hasKey(:responseContent)) {
                text = data[:responseContent].toString();
            } else {
                text = data.toString();
            }

            // Extract the number after "eur"
            var eurStr = extractAfterKey(text, "\"eur\"");

            _priceStr = (eurStr == null) ? "N/A" : eurStr;

            App.getApp().setProperty("lastPrice", _priceStr);
            _lastUpdated = Sys.getClockTime().toString();
        } else {
            _priceStr = "HTTP " + statusCode;
        }
        Ui.requestUpdate();
    }

    // Helper to extract a numeric value that follows a JSON key
    function extractAfterKey(s as Lang.String, key as Lang.String) as Lang.String {
        if (s == null) { return null; }

        var i = s.indexOf(key);
        if (i < 0) { return null; }

        i = s.indexOf(":", i);
        if (i < 0) { return null; }
        i = i + 1;

        // skip spaces/tabs
        while (i < s.length()) {
            var c = s.substring(i, i + 1);
            if (c == " " || c == "\t") {
                i = i + 1;
            } else {
                break;
            }
        }

        // read number (digits + dot or comma)
        var j = i;
        var dotSeen = false;

        while (j < s.length()) {
            var ch = s.substring(j, j + 1);
            if (ch >= "0" && ch <= "9") {
                j = j + 1;
            } else if (ch == "." || ch == ",") {
                if (dotSeen) { break; }
                dotSeen = true;
                j = j + 1;
            } else {
                break;
            }
        }

        if (j > i) {
            return s.substring(i, j);
        }
        return null;
    }

    function onHide() { }
}
