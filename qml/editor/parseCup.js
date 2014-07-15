.pragma library


// www.keepitsoaring.com/LKSC/Downloads/cup_format.pdf‎

function parse(str) {
    var obj = new Object();

    var data = str.toString().split("-----Related Tasks-----");
    if (data.length !== 2) {
        console.error("parseCup.js parse() failed")
        obj.waypoints = [];
        obj.tasks = [];
        return obj;
    }

    obj.waypoints = parseWaypoints(data[0]);
    obj.tasks = parseTasks(data[1])

//    console.log(obj.waypoints)

    return obj;
}

function parseDMLat(str) {
    var reg_exp = /(\d\d)(\d\d\.\d\d\d)([nsNS])/;
    var match = reg_exp.exec(str);

    if (match === null) {
        console.log("error: \"" + str + "\" is not valid Latitude data")
        return 0.0;
    }

    var dir, d, m, s;
    dir = String(match[3]).toUpperCase()
    dir = ((dir === "N" ) ? 1.0 : -1.0);

    d = parseFloat(match[1]);
    m = parseFloat(match[2]);

    d = isNaN(d) ? 0 : d;
    m = isNaN(m) ? 0 : m

    var value = dir * ( d + m/60.0  )

    return value;
}

function parseDMLon(str) {
    var reg_exp = /(\d\d\d)(\d\d\.\d\d\d)([ewEW])/;
    var match = reg_exp.exec(str);

    if (match === null) {
        console.log("error: \"" + str + "\" is not valid Latitude data")
        return 0.0;
    }

    var dir, d, m, s;
    dir = String(match[3]).toUpperCase()
    dir = (( dir === "E" ) ? 1.0 : -1.0);

    d = parseFloat(match[1]);
    m = parseFloat(match[2]);

    d = isNaN(d) ? 0 : d;
    m = isNaN(m) ? 0 : m

    var value = dir * ( d + m/60.0  )

    return value;
}


function parseWaypoints(str) {
    var csvdata = parseCSV(str)
    var arr = [];

    for (var i = 1; i < csvdata.length; i++ ) {
        var csv = csvdata[i]
        if (csv.length < 11) {
            console.log("parseCup parse error (data[i].length < 11): " + csv.length)
            continue
        }

        var obj = {
            "Name" : csv[0],
            "Code" : csv[1],
            "Country" : csv[2],
            "Latitude" : parseDMLat(csv[3]),
            "Longitude" : parseDMLon(csv[4]),
            "Elevation" : csv[5],
            "Waypoint_style" : csv[6],
            "Runway_direction" : csv[7],
            "Runway_length" : csv[8],
            "Airport_Frequency" : csv[9],
            "Description" : csv[10],
            "UserData" : ((csv[11] !== undefined) ? csv[11] : ""),
            "Pics" : ((csv[12] !== undefined) ? csv[12] : ""),

        }

        arr.push(obj)
    }

    return arr;
}

function parseTasks(str) {
    if (str.trim() !== "") {
        console.log("parseTasks is not implemented")
    }

    var csvdata = parseCSV(str)

    // FIXME
//    for (var ri = 0; ri < csvdata.length; ri++) {
//        var row = csvdata[ri];
//        if (row[0] === "Options") {
//            console.log("Options")
//        } else if (row[0].match(/^ObsZone=/)) {
//            console.log("ObsZone")
//        } else {
//            console.log("task")
//        }
//    }


    return csvdata;
}


/*
*/


function parseCSV(str) {
    var arr = [];
    var quote = false;  // true means we're inside a quoted field
    var col, c;

    // iterate over each character, keep track of current row and column (of the returned array)
    for (var row = col = c = 0; c < str.length; c++) {
        var cc = str[c], nc = str[c+1];        // current character, next character
        arr[row] = arr[row] || [];             // create a new row if necessary
        arr[row][col] = arr[row][col] || '';   // create a new column (start with empty string) if necessary

        // If the current character is a quotation mark, and we're inside a
        // quoted field, and the next character is also a quotation mark,
        // add a quotation mark to the current column and skip the next character
        if (cc === '"' && quote && nc === '"') { arr[row][col] += cc; ++c; continue; }

        // If it's just one quotation mark, begin/end quoted field
        if (cc === '"') { quote = !quote; continue; }

        // If it's a comma and we're not in a quoted field, move on to the next column
        if (cc === ',' && !quote) { ++col; continue; }

        // If it's a newline and we're not in a quoted field, move on to the next
        // row and move to column 0 of that new row
        if (cc === '\n' && !quote) { ++row; col = 0; continue; }

        // Otherwise, append the current character to the current column
        arr[row][col] += cc;
    }
    return arr;
}
