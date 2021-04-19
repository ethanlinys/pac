var proxy = "SOCKS5 127.0.0.1:7890;";
var direct = "DIRECT;";

var hasOwnProperty = Object.hasOwnProperty;

var domain_dict = DOMAIN_DICT_PLACEHOLDER;
var subnetIpRangeList = [
    0, 1,
    167772160, 184549376,	//10.0.0.0/8
    2886729728, 2887778304,	//172.16.0.0/12
    3232235520, 3232301056,	//192.168.0.0/16
    2130706432, 2130706688	//127.0.0.0/24
];

function check_ipv4(host) {
    var re_ipv4 = /^\d+\.\d+\.\d+\.\d+$/g;
    if (re_ipv4.test(host)) {
        return true;
    }
}
function convertAddress(ipchars) {
    var bytes = ipchars.split(".");
    var result = (bytes[0] << 24) |
        (bytes[1] << 16) |
        (bytes[2] << 8) |
        (bytes[3]);
    return result >>> 0;
}
function isInSubnetRange(ipRange, intIp) {
    for (var i = 0; i < 10; i += 2) {
        if (ipRange[i] <= intIp && intIp < ipRange[i + 1])
            return true;
    }
}
function getProxyFromDirectIP(strIp) {
    var intIp = convertAddress(strIp);
    if (isInSubnetRange(subnetIpRangeList, intIp)) {
        return direct;
    }
    return proxy;
}
function isInDomains(domain_dict, host) {
    var suffix;
    var pos1 = host.lastIndexOf(".");

    suffix = host.substring(pos1 + 1);
    if (suffix == "cn") {
        return true;
    }

    var domains = domain_dict[suffix];
    if (domains === undefined) {
        return false;
    }
    host = host.substring(0, pos1);
    var pos = host.lastIndexOf(".");

    while (true) {
        if (pos <= 0) {
            if (hasOwnProperty.call(domains, host)) {
                return true;
            } else {
                return false;
            }
        }
        suffix = host.substring(pos + 1);
        if (hasOwnProperty.call(domains, suffix)) {
            return true;
        }
        pos = host.lastIndexOf(".", pos - 1);
    }
}
function FindProxyForURL(url, host) {
    if (isPlainHostName(host) === true) {
        return direct;
    }
    if (check_ipv4(host) === true) {
        return getProxyFromDirectIP(host);
    }
    if (isInDomains(domain_dict, host) === true) {
        return direct;
    }
    return proxy;
}