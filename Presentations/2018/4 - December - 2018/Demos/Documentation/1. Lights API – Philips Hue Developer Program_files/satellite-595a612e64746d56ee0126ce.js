_satellite.pushAsyncScript(function(event, target, $variables){
  // Global floodlight tag
(function (w) {
    var isDebug = _satellite.readCookie("wa_debug") === "true",
        orderValue = 0,
        AddStaticFloodLight = function (strCustVar, strType) {
            var axel = Math.random() + "",
                iframe = document.createElement("iframe"),
                a = 1E13 * axel;
            if (strType === "prodview") {
                // Product tag
                iframe.src = "https://5627815.fls.doubleclick.net/activityi;src=5627815;type=plglobal;cat=plmhprod;" + strCustVar + ";dc_lat=;dc_rdid=;tag_for_child_directed_treatment=;ord=" + a + "?";
            } else if (strType) {
                // Sales tag
                iframe.src = "https://5627815.fls.doubleclick.net/activityi;src=5627815;type=globa0;cat=plmhsale;qty=1;cost=" + orderValue + ";" + strCustVar + ";dc_lat=;dc_rdid=;tag_for_child_directed_treatment=;ord=" + strType + "?";
            } else {
                iframe.src = "https://5627815.fls.doubleclick.net/activityi;src=5627815;type=pageview;cat=plview;" + strCustVar + ";dc_lat=;dc_rdid=;tag_for_child_directed_treatment=;ord=" + a + "?";
            }
            iframe.style.width = "1";
            iframe.style.height = "1";
            iframe.style.frameborder = "0";
            iframe.style.display = "none";
            document.body.appendChild(iframe);
        },
        PopulateCustomVars = function (item) {
            if (item && item.command === "ADD EVENT" && item.name && typeof (item.data) === "object") {

                var strTemp, i, arrVars, arrTemp, fl_type, arrProd = [];
                try {
                    strTemp = item.data.g || w.location.href;
                    strTemp = (strTemp.indexOf("#") >= 0 ? strTemp.substr(0, strTemp.indexOf("#")) : strTemp);
                    arrVars = ["u1=" + strTemp];
                    arrVars.push("u2=" + (item.data.pageName || ""));
                    arrVars.push("u3=" + (item.data.c3 || _satellite.getVar("dlSector")));
                    arrVars.push("u4=" + (item.data.c2 || _satellite.getVar("dlLanguage")));
                    arrVars.push("u5=" + (item.data.c1 || _satellite.getVar("dlCountry")));
                    arrTemp = (item.data.products || "").split(",");
                    // Get product name
                    for (i = 0; i < arrTemp.length; i++) {
                        strTemp = (arrTemp[i].indexOf(";") === -1 ? arrTemp[i] : arrTemp[i].split(";")[1] || "");
                        strTemp && arrProd.push(strTemp);
                    }
                    arrVars.push("u6=" + arrProd.join("|"));
                    arrVars.push("u31=" + arrProd.join("|"));
                    // Get product price
                    arrProd = [];
                    for (i = 0; i < arrTemp.length; i++) {
                        strTemp = (arrTemp[i].indexOf(";") === -1 ? arrTemp[i] : arrTemp[i].split(";")[3] || "");
                        if (strTemp) {
                            arrProd.push(strTemp);
                            orderValue += parseFloat(strTemp) || 0;
                        }
                    }
                    arrVars.push("u7=" + arrProd.join("|"));
                    arrVars.push("u8=" + (item.data.cc || s.currencyCode)); // NOTE: dependency on s-object
                    for (i = 5; i < 9; i++) {
                        try {
                            strTemp = item.data["c" + i] || "";
                            arrVars.push("u" + (i + 4) + "=" + (strTemp.indexOf(":level_not_set:") === -1 ? strTemp.split(":").pop() : ""));
                        } catch(e){}
                    }
                    arrVars.push("u13=" + (item.data.v9 || ""));
                    // u14=[specialty]
                    arrVars.push("u15=" + (item.data.v24 || ""));
                    arrVars.push("u16=" + (item.data.pev1 || ""));
                    arrVars.push("u24=" + (item.data.mid || ""));
                    arrVars.push("u25=" + (item.data.c10 || ""));
                    strTemp = (item.data.v77 || "").split(":").shift();
                    arrTemp = strTemp.split("&");
                    // Add pageview event description if event38 is set
                    if ((item.data.events || "").indexOf("event38") >= 0) {
                        if (arrTemp[0] === "") {
                            arrTemp = ["pageview"];
                        } else {
                            arrTemp.push("pageview");
                        }
                    }
                    if ((item.data.events || "").indexOf("scAdd") >= 0) {
                        if (arrTemp[0] === "") {
                            arrTemp = ["add_to_cart"];
                        } else {
                            arrTemp.push("add_to_cart");
                        }
                    }
                    fl_type = (arrTemp.indexOf("prodview") !== -1 ? "prodview" : item.data.purchaseID || "");
                    arrVars.push("u26=" + arrTemp.join("|"));
                    arrVars.push("u27=" + (item.data.v0 || ""));
                    arrVars.push("u28=" + _satellite.getVar("cookieDomainLI"));
                    arrVars.push("u29=" + (item.data.ch || s.channel).split(":").pop());    // NOTE: still dependency on s-object
                    arrVars.push("u30=" + (item.data.c33 || ""));
                } catch (err) {
                    isDebug && console.info("[FL] Error occured in PopulateCustomVars: " + err);
                }
                strTemp = arrVars.join(";");
                // Abort if repeat request or no conversion found in u26
                if (strTemp === s.fl_req || arrVars.indexOf("u26=") !== -1) {
                    isDebug && console.info("[FL] Not set (duplicate or empty)");
                    return;
                }
                AddStaticFloodLight(strTemp, fl_type);
                s.fl_req = strTemp;
                isDebug && console.info("[FL] Set with custom vars=" + strTemp);
            }
        };

    // Measure pagesviews and in-page interactions
    var aaResponder = _satellite.getVar("Utils-Responder");
    aaResponder.registerCallback(PopulateCustomVars);
    aaResponder.activate();

})(window);
});
