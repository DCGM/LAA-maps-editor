.pragma library

function arrayFromMask (nMask) {
    // nMask must be between -2147483648 and 2147483647
    if (nMask > 0x7fffffff || nMask < -0x80000000) { throw new TypeError("arrayFromMask - out of range"); }
    for (var nShifted = nMask, aFromMask = []; nShifted; aFromMask.push(Boolean(nShifted & 1)), nShifted >>>= 1);
    return aFromMask;
}

function basename(path) {
    return String(path).replace(/.*\/|\.[^.]*$/g, '');
}

function addSlashes(input) {
    return String(input).replace(/\\/g, '\\\\').replace(/"/g, '\\"');
}





function addTimeStrFormat(str) {
    var t = parseInt(str, 10);
    if (t >= 0) {
        var hours = Math.floor(t/3600)
        var minutes = Math.floor((t%3600)/60)
        var seconds = Math.floor(t%60);
        return pad2(hours) + ":" + pad2(minutes) + ":" + pad2(seconds)
    } else {
        return t
    }
}

function pad2(i) {
    if (i < 10) {
        return "0" + i;
    }
    return String(i);
}

function getPolyByCid(cid, poly) {
    for (var i = 0; i < poly.length; i++) {
        var item = poly[i];
        if (item.cid === cid) {
            return item;
        }
    }
}

function getFlagsByIndex(flag_index, value) {
    var mask = (0x1 << flag_index);
    return ((value & mask) === mask);
}


