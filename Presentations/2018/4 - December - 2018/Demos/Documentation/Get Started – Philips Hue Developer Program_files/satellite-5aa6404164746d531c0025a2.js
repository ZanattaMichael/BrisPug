_satellite.pushAsyncScript(function(event, target, $variables){
  /*
1st click capture code
*/

window._mTrack = window._mTrack || [];
window._mTrack.push(['trackPage']);

(function () {
    var mClientId = 'iwnljcerg0';
    var mProto = ('https:' == document.location.protocol ? 'https://' : 'http://');
    var mHost = 'tracker.marinsm.com';
    var mt = document.createElement('script');
    mt.type = 'text/javascript';
    mt.async = true;
    mt.src = mProto + mHost + '/tracker/async/' + mClientId + '.js';
    //var fscr = document.getElementsByTagName('script')[0]; fscr.parentNode.insertBefore(mt, fscr);
    var fscr = document.getElementsByTagName('head')[0];
    fscr.appendChild(mt);
})();

/*
2nd conversion capture code
*/
function captureMarinConversion(item) {
    if (item && item.command === "ADD EVENT" && item.name && typeof (item.data) === "object") {

        if (document.querySelectorAll('[src*="tracker.marinsm.com/tracker/async"]').length > 0) {
            mScript = document.querySelectorAll('[src*="tracker.marinsm.com/tracker/async"]')[0];
            mScript.parentNode.removeChild(mScript);
        }

        /* all events*/
        // var conversionTypes = ["find_retail_store","find_online_store","retail_store_results","online_store_results","user_registration","product_registration","share","download","sales_lead","buy","buy_at_philips","buy_at_others","compare_products","apply_at_philips","contact_philips","info_request","rss_feed","user_login","interaction","video_start","video_50","video_25","video_75","video_end","like","phone_call","follow_us","search","exit_link","exit_link_b2c","chat","print","prodview","add_to_cart","remove_from_cart","checkout","order","pageview","visit_start","cart_view","cart_open"];

        // Only use these events
        var conversionTypes = ["add_to_cart", "order", "buy_at_others", "find_retail_store", "user_registration", "download", "video_start", "video_50", "video_end", "prodview", "cart_view", "buy", "follow_us", "info_request", "share", "checkout", "visit_start", "ext_campaign_landing"];
        var eventMt = [];
        var eventDescriptionMarin = (item.data.v77 || "").split(':')[0];
        // interaction -> chat 
        // if (eventDescriptionMarin=="interaction" && ((item.data.v77 || "").indexOf('interaction:chat')>-1 ) ) {eventDescriptionMarin="chat";}
        var eventTranslation = { // use marin mt conversions
            "video_0": "video_start",
            "video_100": "video_end",
            //"scOpen": "cart_open",
            "scAdd": "add_to_cart",
            //"scRemove": "remove_from_cart",
            "scView": "cart_view",
            "scCheckout": "checkout",
            "purchase": "order",
            "social_like": "like"
            //"user_login" : "login",
            //"internal_search_1" : "search",
            //"internal_search_0" : "search"
        };

        if (eventTranslation[eventDescriptionMarin]) {
            eventDescriptionMarin = eventTranslation[eventDescriptionMarin];
        }

        if (eventDescriptionMarin != "" && conversionTypes.indexOf(eventDescriptionMarin) > -1) {
            eventMt.push(eventDescriptionMarin);
        }
        var eventAA = (item.data.events || "").split(',');
        //if (eventAA.indexOf('event38')>-1){eventMt.push('pageview');}
        if (eventAA.indexOf('event47') > -1) {
            eventMt.push('ext_campaign_landing');
        }
        //if (eventAA.indexOf('event33')>-1){eventMt.push('apply_at_philips');}
        //if (eventAA.indexOf('event35')>-1){eventMt.push('rss_feed');}
        if (eventAA.indexOf('event7') > -1) {
            eventMt.push('visit_start');
        }
        if (eventAA.indexOf('scAdd') > -1) {
            eventMt.push('add_to_cart');
        }
        if (eventAA.indexOf('scCheckout') > -1) {
            eventMt.push('checkout');
        }
        if (eventAA.indexOf('purchase') > -1) {
            eventMt.push('order');
        }
        //if (eventAA.indexOf('scOpen')>-1){eventMt.push('cart_open');}
        //if (eventAA.indexOf('scRemove')>-1){eventMt.push('remove_from_cart');}
        if (eventAA.indexOf('scView') > -1) {
            eventMt.push('cart_view');
        }
        if (eventAA.indexOf('prodView') > -1) {
            eventMt.push('prodview');
        }
        //if (eventAA.indexOf('event46')>-1){eventMt.push('interaction');}

        /*
          var pev2 = item.data.pev2 || "" ;
          if( (pev2.indexOf(":print", pev2.length - ":print".length)) !== -1 ){
            eventMt.push('print');
          }
        */

        var currency = "" + (item.data.cc || s.currencyCode || "EUR");  // NOTE: still reference to s-object
        var orderId = "" + (item.data.v11 || item.data.purchaseId || s.purchaseID);
        var productString = (item.data.products || s.products || _satellite.getVar('dlProduct'));   // NOTE: still reference to s-object
        var productItems = productString ? productString.split(',') : "";
        // dedupe
        eventMt = eventMt.filter(function (el, i, eventMt) {
            return eventMt.indexOf(el) === i;
        });

        var transItems = [];
        eventMt.forEach(function (value, index) {
            var convType = value;
            var transItem = {};
            if (productItems == "") {
                //1) Push without productID
                if (convType !== "") {
                    transItem.convType = "mt_" + convType;
                    transItems.push(transItem);
                }
            } else {
                // push 1 or multiple items with productIds
                var arrProducts = [];
                transItem.price = 0;
                transItem.quantity = 0;
                // checkout or purchase 
                productItems.forEach(function (value, index) {
                    if (value != "") {
                        var productData = value.split(';');
                        var productId = productData[1];
                        var quantity = productData[2];
                        var totalPrice = productData[3];
                        try {
                            productPrice = totalPrice / quantity;
                        } catch (e) {}
                        if (productId) arrProducts.push(productId);
                        if (totalPrice) transItem.price = Number(transItem.price) + Number(totalPrice);
                        if (quantity) transItem.quantity = Number(transItem.quantity) + Number(quantity);
                    }
                });

                // Clean quantity and price if not set
                if (isNaN(transItem.quantity) || transItem.quantity === 0) {
                    transItem.quantity = "";
                }
                if (isNaN(transItem.price) || transItem.price === 0) {
                    transItem.price = "";
                }

                if (convType !== "") {
                    if (orderId !== "undefined") transItem.orderId = orderId;
                    transItem.convType = "mt_" + convType;

                    try {
                        if (_satellite.getVar('dlProductCategory')) {
                            transItem.category = _satellite.getVar('dlProductCategory');
                        }
                    } catch (e) {}

                    transItem.product = arrProducts.join(";");

                    transItems.push(transItem);
                }
            }
        });

        if (transItems.length > 0) {
            window._mTrack = window._mTrack || [];
            window._mTrack.push(['addTrans', {
                currency: currency,
                items: transItems
            }]);

            window._mTrack.push(['processOrders']);
            (function () {
                var mClientId = 'iwnljcerg0';
                var mProto = (('https:' == document.location.protocol) ? 'https://' : 'http://');
                var mHost = 'tracker.marinsm.com';
                var mt = document.createElement('script');
                mt.type = 'text/javascript';
                mt.async = true;
                mt.src = mProto + mHost + '/tracker/async/' + mClientId + '.js';
                //var fscr = document.getElementsByTagName('script')[0]; fscr.parentNode.insertBefore(mt, fscr);
                var fscr = document.getElementsByTagName('head')[0];
                fscr.appendChild(mt);
            })();
        }
    }
}

var aaResponder = _satellite.getVar("Utils-Responder");
    aaResponder.registerCallback(captureMarinConversion);
    aaResponder.activate();
});
