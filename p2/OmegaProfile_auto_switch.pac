var FindProxyForURL = function(init, profiles) {
    return function(url, host) {
        "use strict";
        var result = init, scheme = url.substr(0, url.indexOf(":"));
        do {
            result = profiles[result];
            if (typeof result === "function") result = result(url, host, scheme);
        } while (typeof result !== "string" || result.charCodeAt(0) === 43);
        return result;
    };
}("+auto switch", {
    "+auto switch": function(url, host, scheme) {
        "use strict";
        if (/^internal\.example\.com$/.test(host)) return "DIRECT";
        if (/^http:\/\/app1\.com$/.test(host)) return "+Inception-of-Things";
        if (/^http:\/\/app2\.com$/.test(host)) return "+Inception-of-Things";
        if (/^http:\/\/app3\.com$/.test(host)) return "+Inception-of-Things";
        return "+__ruleListOf_auto switch";
    },
    "+__ruleListOf_auto switch": "+Inception-of-Things",
    "+Inception-of-Things": function(url, host, scheme) {
        "use strict";
        if (/^127\.0\.0\.1$/.test(host) || /^::1$/.test(host) || /^localhost$/.test(host)) return "DIRECT";
        return "PROXY 192.168.56.110:80";
    }
});