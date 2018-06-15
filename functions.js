.pragma library

var earth_radius = 6371000;
var global_center_lat = 0;
var global_center_lon = 0;
var originShift = 2 * Math.PI * 6378137 / 2.0


/* Ellipsoid model constants (actual values here are for WGS84) */
var sm_a = 6378137.0;
var sm_b = 6356752.314;
var sm_EccSquared = 6.69437999013e-03;

var UTMScaleFactor = 0.9996;

function rad2deg (rad) {
    return (180*rad)/Math.PI;
}

function rad2degPair (rad) {
    return [rad2deg(rad[0]), rad2deg(rad[1])]
}


function deg2rad (deg) {
    return (deg/180)*Math.PI;
}

function deg2radPair (deg) {
    return [deg2rad(deg[0]), deg2rad(deg[1])]
}


function formatDistance(d, settings) {
    if (! d) {
        return "0"
    }

    if (settings.distanceUnit === 'm') {
        if (d >= 15000) {
            return Math.round(d / 1000.0) + " km"
        } else if (d >= 3000) {
            return (d / 1000.0).toFixed(1) + " km"
        } else if (d >= 100) {
            return Math.round(d) + " m"
        } else {
            return d.toFixed(1) + " m"
        }
    }
}

function formatBearing(b) {
    return Math.round(b) + "°"
}

function formatCoordinate(lat, lon, c) {
    return getLat(lat, c) + " " + getLon(lon, c)
}

function getDM(l) {
    var out = Array(3);
    out[0] = (l > 0) ? 1 : -1
    l = out[0] * l
    out[1] = ("00" + Math.floor(l)).substr(-3, 3)
    out[2] = ("00" + ((l - Math.floor(l)) * 60).toFixed(3)).substr(-6, 6)
    return out
}

function getValueFromDM(sign, deg, min) {
    return sign*(deg + (min/60))
}

function getLat(lat, settings) {
    var l = Math.abs(lat)
    var c = "N";
    if (lat < 0) {
        c = "S"
    }
    if (settings.coordinateFormat === "D") {
        return c + " " + l.toFixed(5) + "°"
    } else if (settings.coordinateFormat === "DM") {
        var mxt = (l - Math.floor(l)) * 60
        var s = (mxt - Math.floor(mxt))
        return ("00" + Math.floor(l)).slice(-2) + ("00"+Math.floor(mxt)).slice(-2)+ "." + ("000" + s.toFixed(3)*1000).slice(-3) + c
    } else if (settings.coordinateFormat === "DMS") {
        var mxt = (l - Math.floor(l)) * 60
        var s = (mxt - Math.floor(mxt)) * 60
        return c + " "+ Math.floor(l) + "° " + Math.floor(mxt) + "' " + s.toFixed(5) + "''"
    } else {
        return c + " " + Math.floor(l) + "° " + ((l - Math.floor(l)) * 60).toFixed(3) + "'"
    }
}


function getLon(lon, settings) {
    var l = Math.abs(lon)
    var c = "E";
    if (lon < 0) {
        c = "W"
    }
    if (settings.coordinateFormat === "D") {
        return c + " " + l.toFixed(5) + "°"
    } else if (settings.coordinateFormat === "DM") {
        var mxt = (l - Math.floor(l)) * 60
        var s = (mxt - Math.floor(mxt))
        return ("000" + Math.floor(l)).slice(-3) + ("00"+Math.floor(mxt)).slice(-2)+ "." + ("000" + s.toFixed(3)*1000).slice(-3) + c
    } else if (settings.coordinateFormat === "DMS") {
        var mxt = (l - Math.floor(l)) * 60
        var s = (mxt - Math.floor(mxt)) * 60
        return c + " "+ Math.floor(l) + "° " + Math.floor(mxt) + "' " + s.toFixed(5) + "''"
    } else {
        return c + " " + Math.floor(l) + "° " + ((l - Math.floor(l)) * 60).toFixed(3) + "'"
    }
}

function distToAngle (meters) {
    var angle_radians = Math.asin(meters/earth_radius);
    return rad2deg(angle_radians);
}

function insertEdgeArc(p3_lat, p3_lon, start_lat, start_lon, end_lat, end_lon, cw) {
    return [];
}



function insertMidArc(control_lat, control_lon, start_lat, start_lon, end_lat, end_lon, cw) {

    // computed as average distance the center of the arc has to be in same distance from both points (start/end)

    var x3 = 0.5*(start_lat+end_lat);
    var y3 = 0.5*(start_lon+end_lon);

    var distance = getDistanceTo(control_lat, control_lon, x3, y3)

    var angle = getBearingTo(start_lat, start_lon, end_lat, end_lon)

    var centerA = getCoordByDistanceBearing(x3, y3, angle+90, distance)
    var centerB = getCoordByDistanceBearing(x3, y3, angle+270, distance)


    var d1 = getDistanceTo(centerA.lat, centerA.lon, control_lat, control_lon)
    var d2 = getDistanceTo(centerB.lat, centerB.lon, control_lat, control_lon)
    var distance = getDistanceTo(centerA.lat, centerA.lon, start_lat, start_lon)

    if (d1 < d2) {
        var center_lat = centerA.lat
        var center_lon = centerA.lon
    } else {
        var center_lat = centerB.lat
        var center_lon = centerB.lon
    }


    global_center_lat = center_lat;
    global_center_lon = center_lon;


    var r = distToAngle(distance);

    var a1 = angleRad(center_lat, center_lon, start_lat, start_lon)
    var a2 = angleRad(center_lat, center_lon, end_lat, end_lon)


    //    console.log("insertMidArcByAngle("+center_lat+", "+center_lon+", "+a1+", "+a2+", "+cw+", "+r+")")
    return insertMidArcByAngle(center_lat, center_lon, a1, a2, cw, r);

}

var ARC_GRANULARITY = 0.05;

// from/to angle
function insertMidArcByAngle(center_lat, center_lon, from, to, clock_wise, radius) {
    var result = [];
    var from_to_diff = Math.abs(from - to);
    ARC_GRANULARITY = (from_to_diff < 0.25) ? 0.25 * from_to_diff : 0.05; // ensure at least 5 points in arc

    if (clock_wise) {
        if (to < from) {
            to += 2*Math.PI;
        }
        for (var angle = from + ARC_GRANULARITY; angle < to; angle += ARC_GRANULARITY) {
            result.push(computeArcPoint(center_lat,center_lon, radius, angle))
        }

    } else {
        if (from < to) {
            from += 2*Math.PI;
        }
        for (var angle = from - ARC_GRANULARITY; angle > to; angle -= ARC_GRANULARITY) {
            result.push(computeArcPoint(center_lat,center_lon, radius, angle))
        }

    }
    return result;
}

function angleRad(center_lat, center_lon, poi_lat, poi_lon) {
    var lat = poi_lat - center_lat;
    var lon = (poi_lon - center_lon) * Math.cos(deg2rad(poi_lat))
    return Math.atan2(lon, lat);
}


function computeArcPoint(clat, clon, r, partAngle) {

    var lon = Math.sin(partAngle) * r;
    var lat = Math.cos(partAngle) * r;
    var rlat = clat + lat;
    var rlon = clon + lon / Math.cos ( deg2rad (rlat) )

    return [rlat, rlon];
}


function DMStoFloat(str) {
    var reg_exp = /([nsewNSEW])\s*(\d*)°\s*(\d*)'?\s*(\d*\.?\d*)'?'?/;
    var match = reg_exp.exec(str);

    if (match === null) {
        console.log("error: \"" + str + "\" is not valid Latitude/Longitude data")

        return parseFloat(str, 0);
    }

    var dir, d, m, s;
    dir = String(match[1]).toUpperCase()
    dir = ((dir === "N" || dir === "E" ) ? 1.0 : -1.0);

    d = parseFloat(match[2]);
    m = parseFloat(match[3]);
    s = parseFloat(match[4]);
    d = isNaN(d) ? 0 : d;
    m = isNaN(m) ? 0 : m
    s = isNaN(s) ? 0 : s;

    var value = dir * ( d + m/60.0 + s/3600.0 )

    return value;
}


function getMapTile(url, x, y, zoom, subdomains) {
    var result = url.replace("%(x)d", x).replace("%(y)d", y).replace("%(zoom)d", zoom);
    if ((subdomains !== undefined) && (subdomains.length > 0)) {
        var rand = Math.floor((Math.random() * subdomains.length));
        result = result.replace("%(s)d", subdomains[rand]);
    }

    return result;
}

function getBearingTo(lat, lon, tlat, tlon) {
    var lat1 = lat * (Math.PI/180.0);
    var lat2 = tlat * (Math.PI/180.0);

    var dlon = (tlon - lon) * (Math.PI/180.0);
    var y = Math.sin(dlon) * Math.cos(lat2);
    var x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dlon);
    return (360 + (Math.atan2(y, x)) * (180.0/Math.PI)) % 360;
}

function getDistanceTo(lat, lon, tlat, tlon) {
    var dlat = Math.pow(Math.sin((tlat-lat) * (Math.PI/180.0) / 2), 2)
    var dlon = Math.pow(Math.sin((tlon-lon) * (Math.PI/180.0) / 2), 2)
    var a = dlat + Math.cos(lat * (Math.PI/180.0)) * Math.cos(tlat * (Math.PI/180.0)) * dlon;
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return 6371000.0 * c;
}

function euclidDistance(a_x, a_y, b_x, b_y) {
    var d_x = a_x-b_x;
    var d_y = a_y-b_y;
    return Math.sqrt(d_x*d_x + d_y*d_y);
}

function lineIntersection(Ax, Ay, Bx, By, Cx, Cy, Dx, Dy) {

    //  Fail if either line is undefined.
    if (Ax===Bx && Ay===By || Cx===Dx && Cy===Dy) return false;

    //  Fail if the segments share an end-point.
    if (Ax===Cx && Ay===Cy || Bx===Cx && By===Cy
            ||  Ax===Dx && Ay===Dy || Bx===Dx && By===Dy) {
        return false; }

    //  (1) Translate the system so that point A is on the origin.
    Bx-=Ax; By-=Ay;
    Cx-=Ax; Cy-=Ay;
    Dx-=Ax; Dy-=Ay;

    //  Discover the length of segment A-B.
    var distAB = Math.sqrt(Bx*Bx+By*By);

    //  (2) Rotate the system so that point B is on the positive X axis.
    var theCos=Bx/distAB;
    var theSin=By/distAB;
    var newX=Cx*theCos+Cy*theSin;
    Cy  =Cy*theCos-Cx*theSin; Cx=newX;
    newX=Dx*theCos+Dy*theSin;
    Dy  =Dy*theCos-Dx*theSin; Dx=newX;

    //  Fail if segment C-D doesn't cross line A-B.
    if (Cy<0. && Dy<0. || Cy>=0. && Dy>=0.) return false;

    //  (3) Discover the position of the intersection point along line A-B.
    var ABpos=Dx+(Cx-Dx)*Dy/(Dy-Cy);

    //  Fail if segment C-D crosses line A-B outside of segment A-B.
    if (ABpos<0. || ABpos>distAB) return false;

    //  (4) Apply the discovered position to line A-B in the original coordinate system.
    var X=Ax+ABpos*theCos;
    var Y=Ay+ABpos*theSin;

    //  Success.
    return true;

}

function latLonToMeters(lat, lon) {
    var mx = lon * originShift / 180.0
    var my = Math.log( Math.tan ( (90 + lat) * Math.PI / 360.0  ) ) / (Math.PI / 180);
    my = my * originShift / 180.0
    return [mx, my]
}

//    "Converts XY point from Spherical Mercator EPSG:900913 to lat/lon in WGS84 Datum"

function metersToLatLon(mx, my) {

    var lon = (mx / originShift) * 180.0;
    var lat = (my / originShift) * 180.0;

    lat = 180 / Math.PI * (2 * Math.atan( Math.exp( lat * Math.PI / 180.0)) - Math.PI / 2.0);
    return [lat, lon];
}

/**
  * Makes perpendicular projection of point to line
  * point C projected to line AB
  */

function projectionPointToLineLatLon(Ax, Ay, Bx, By, Cx,Cy) {

    var A = latLonToMeters(Ax, Ay)
    var B = latLonToMeters(Bx, By)
    var C = latLonToMeters(Cx, Cy)

    var D = projectionPointToLine(A[0], A[1], B[0], B[1], C[0], C[1])

    return metersToLatLon(D[0], D[1]);
}

/**
  * point C projected to line AB
  */

function projectionPointToLine(Ax, Ay, Bx, By, Cx, Cy) {


    var px = Bx - Ax;
    var py = By - Ay;

    var u =  ((Cx - Ax) * px + (Cy - Ay) * py) / (px * px + py * py)


    if (u > 1) {
        u = 1;
    } else if (u < 0) {
        u = 0;
    }

    var x = Ax + u * px;
    var y = Ay + u * py;

    return [x, y];


/*
    var ACdistance = getDistanceTo(Ax, Ay, Cx, Cy)
    var BCdistance = getDistanceTo(Bx, By, Cx, Cy)

    var ACratio = ACdistance/(ACdistance + BCdistance)

    var Dx = Ax * (1 - ACratio) + Bx * ACratio;
    var Dy = Ay * (1 - ACratio) + By * ACratio;

    return [Dx, Dy]
    */
}



function getCoordByDistanceBearing(lat, lon, bear, dist) {

    var lat1 = deg2rad(lat);
    var lon1 = deg2rad(lon);
    var brng = deg2rad(bear);
    var d = dist/earth_radius;  // uhlova vzdalenost

    var dlat = d * Math.cos ( brng );
    if (Math.abs(dlat) < 1E-10) {
        dlat = 0;
    }

    var lat2 = lat1 + dlat;
    var dphi = Math.log(Math.tan(lat2/2+Math.PI/4)/Math.tan(lat1/2+Math.PI/4));


    var q = (isFinite(dlat/dphi)) ? dlat/dphi : Math.cos(lat1);  // E-W line gives dPhi=0

    var dLon = d*Math.sin(brng)/q;

    if (Math.abs(lat2) > Math.PI/2) {
        lat2 = (lat2 > 0) ? Math.PI-lat2 : -Math.PI-lat2;
    }


    var lon2 = (lon1+dLon+Math.PI)%(2*Math.PI) - Math.PI;

    return {lat: rad2deg(lat2),lon: rad2deg(lon2)};

}



String.prototype.trunc =
        function(n,useWordBoundary){
            var toLong = this.length>n,
                    s_ = toLong ? this.substr(0,n-1) : this;
            s_ = useWordBoundary && toLong ? s_.substr(0,s_.lastIndexOf(' ')) : s_;
            return  toLong ? s_ +'...' : s_;
        };




/////////// http://home.hiwaay.net/~taylorc/toolbox/geography/geoutm.html


/*
    * arcLengthOfMeridian
    *
    * Computes the ellipsoidal distance from the equator to a point at a
    * given latitude.
    *
    * Reference: Hoffmann-Wellenhof, B., Lichtenegger, H., and Collins, J.,
    * GPS: Theory and Practice, 3rd ed.  New York: Springer-Verlag Wien, 1994.
    *
    * Inputs:
    *     phi - Latitude of the point, in radians.
    *
    * Globals:
    *     sm_a - Ellipsoid model major axis.
    *     sm_b - Ellipsoid model minor axis.
    *
    * Returns:
    *     The ellipsoidal distance of the point from the equator, in meters.
    *
    */

function arcLengthOfMeridian (phi)
{
    var alpha, beta, gamma, delta, epsilon, n;
    var result;

    /* Precalculate n */
    n = (sm_a - sm_b) / (sm_a + sm_b);

    /* Precalculate alpha */
    alpha = ((sm_a + sm_b) / 2.0)
            * (1.0 + (Math.pow (n, 2.0) / 4.0) + (Math.pow (n, 4.0) / 64.0));

    /* Precalculate beta */
    beta = (-3.0 * n / 2.0) + (9.0 * Math.pow (n, 3.0) / 16.0)
            + (-3.0 * Math.pow (n, 5.0) / 32.0);

    /* Precalculate gamma */
    gamma = (15.0 * Math.pow (n, 2.0) / 16.0)
            + (-15.0 * Math.pow (n, 4.0) / 32.0);

    /* Precalculate delta */
    delta = (-35.0 * Math.pow (n, 3.0) / 48.0)
            + (105.0 * Math.pow (n, 5.0) / 256.0);

    /* Precalculate epsilon */
    epsilon = (315.0 * Math.pow (n, 4.0) / 512.0);

    /* Now calculate the sum of the series and return */
    result = alpha
            * (phi + (beta * Math.sin (2.0 * phi))
               + (gamma * Math.sin (4.0 * phi))
               + (delta * Math.sin (6.0 * phi))
               + (epsilon * Math.sin (8.0 * phi)));

    return result;
}

/*
   * utmCentralMeridian
   *
   * Determines the central meridian for the given UTM zone.
   *
   * Inputs:
   *     zone - An integer value designating the UTM zone, range [1,60].
   *
   * Returns:
   *   The central meridian for the given UTM zone, in radians, or zero
   *   if the UTM zone parameter is outside the range [1,60].
   *   Range of the central meridian is the radian equivalent of [-177,+177].
   *
   */
function utmCentralMeridian  (zone)
{
    var cmeridian;

    cmeridian = deg2rad (-183.0 + (zone * 6.0));

    return cmeridian;
}



/*
   * footpointLatitude
   *
   * Computes the footpoint latitude for use in converting transverse
   * Mercator coordinates to ellipsoidal coordinates.
   *
   * Reference: Hoffmann-Wellenhof, B., Lichtenegger, H., and Collins, J.,
   *   GPS: Theory and Practice, 3rd ed.  New York: Springer-Verlag Wien, 1994.
   *
   * Inputs:
   *   y - The UTM northing coordinate, in meters.
   *
   * Returns:
   *   The footpoint latitude, in radians.
   *
   */
function footpointLatitude (y)
{
    var y_, alpha_, beta_, gamma_, delta_, epsilon_, n;
    var result;

    /* Precalculate n (Eq. 10.18) */
    n = (sm_a - sm_b) / (sm_a + sm_b);

    /* Precalculate alpha_ (Eq. 10.22) */
    /* (Same as alpha in Eq. 10.17) */
    alpha_ = ((sm_a + sm_b) / 2.0)
            * (1 + (Math.pow (n, 2.0) / 4) + (Math.pow (n, 4.0) / 64));

    /* Precalculate y_ (Eq. 10.23) */
    y_ = y / alpha_;

    /* Precalculate beta_ (Eq. 10.22) */
    beta_ = (3.0 * n / 2.0) + (-27.0 * Math.pow (n, 3.0) / 32.0)
            + (269.0 * Math.pow (n, 5.0) / 512.0);

    /* Precalculate gamma_ (Eq. 10.22) */
    gamma_ = (21.0 * Math.pow (n, 2.0) / 16.0)
            + (-55.0 * Math.pow (n, 4.0) / 32.0);

    /* Precalculate delta_ (Eq. 10.22) */
    delta_ = (151.0 * Math.pow (n, 3.0) / 96.0)
            + (-417.0 * Math.pow (n, 5.0) / 128.0);

    /* Precalculate epsilon_ (Eq. 10.22) */
    epsilon_ = (1097.0 * Math.pow (n, 4.0) / 512.0);

    /* Now calculate the sum of the series (Eq. 10.21) */
    result = y_ + (beta_ * Math.sin (2.0 * y_))
            + (gamma_ * Math.sin (4.0 * y_))
            + (delta_ * Math.sin (6.0 * y_))
            + (epsilon_ * Math.sin (8.0 * y_));

    return result;
}



/*
   * mapLatLonToXY
   *
   * Converts a latitude/longitude pair to x and y coordinates in the
   * Transverse Mercator projection.  Note that Transverse Mercator is not
   * the same as UTM; a scale factor is required to convert between them.
   *
   * Reference: Hoffmann-Wellenhof, B., Lichtenegger, H., and Collins, J.,
   * GPS: Theory and Practice, 3rd ed.  New York: Springer-Verlag Wien, 1994.
   *
   * Inputs:
   *    phi - Latitude of the point, in radians.
   *    lambda - Longitude of the point, in radians.
   *    lambda0 - Longitude of the central meridian to be used, in radians.
   *
   * Outputs:
   *    xy - A 2-element array containing the x and y coordinates
   *         of the computed point.
   *
   * Returns:
   *    The function does not return a value.
   *
   */
function mapLatLonToXY (phi, lambda, lambda0, xy)
{
    var N, nu2, ep2, t, t2, l;
    var l3coef, l4coef, l5coef, l6coef, l7coef, l8coef;
    var tmp;

    /* Precalculate ep2 */
    ep2 = (Math.pow (sm_a, 2.0) - Math.pow (sm_b, 2.0)) / Math.pow (sm_b, 2.0);

    /* Precalculate nu2 */
    nu2 = ep2 * Math.pow (Math.cos (phi), 2.0);

    /* Precalculate N */
    N = Math.pow (sm_a, 2.0) / (sm_b * Math.sqrt (1 + nu2));

    /* Precalculate t */
    t = Math.tan (phi);
    t2 = t * t;
    tmp = (t2 * t2 * t2) - Math.pow (t, 6.0);

    /* Precalculate l */
    l = lambda - lambda0;

    /* Precalculate coefficients for l**n in the equations below
          so a normal human being can read the expressions for easting
          and northing
          -- l**1 and l**2 have coefficients of 1.0 */
    l3coef = 1.0 - t2 + nu2;

    l4coef = 5.0 - t2 + 9 * nu2 + 4.0 * (nu2 * nu2);

    l5coef = 5.0 - 18.0 * t2 + (t2 * t2) + 14.0 * nu2
            - 58.0 * t2 * nu2;

    l6coef = 61.0 - 58.0 * t2 + (t2 * t2) + 270.0 * nu2
            - 330.0 * t2 * nu2;

    l7coef = 61.0 - 479.0 * t2 + 179.0 * (t2 * t2) - (t2 * t2 * t2);

    l8coef = 1385.0 - 3111.0 * t2 + 543.0 * (t2 * t2) - (t2 * t2 * t2);

    /* Calculate easting (x) */
    xy[0] = N * Math.cos (phi) * l
            + (N / 6.0 * Math.pow (Math.cos (phi), 3.0) * l3coef * Math.pow (l, 3.0))
            + (N / 120.0 * Math.pow (Math.cos (phi), 5.0) * l5coef * Math.pow (l, 5.0))
            + (N / 5040.0 * Math.pow (Math.cos (phi), 7.0) * l7coef * Math.pow (l, 7.0));

    /* Calculate northing (y) */
    xy[1] = arcLengthOfMeridian (phi)
            + (t / 2.0 * N * Math.pow (Math.cos (phi), 2.0) * Math.pow (l, 2.0))
            + (t / 24.0 * N * Math.pow (Math.cos (phi), 4.0) * l4coef * Math.pow (l, 4.0))
            + (t / 720.0 * N * Math.pow (Math.cos (phi), 6.0) * l6coef * Math.pow (l, 6.0))
            + (t / 40320.0 * N * Math.pow (Math.cos (phi), 8.0) * l8coef * Math.pow (l, 8.0));

    return;
}



/*
   * mapXYToLatLon
   *
   * Converts x and y coordinates in the Transverse Mercator projection to
   * a latitude/longitude pair.  Note that Transverse Mercator is not
   * the same as UTM; a scale factor is required to convert between them.
   *
   * Reference: Hoffmann-Wellenhof, B., Lichtenegger, H., and Collins, J.,
   *   GPS: Theory and Practice, 3rd ed.  New York: Springer-Verlag Wien, 1994.
   *
   * Inputs:
   *   x - The easting of the point, in meters.
   *   y - The northing of the point, in meters.
   *   lambda0 - Longitude of the central meridian to be used, in radians.
   *
   * Outputs:
   *   philambda - A 2-element containing the latitude and longitude
   *               in radians.
   *
   * Returns:
   *   The function does not return a value.
   *
   * Remarks:
   *   The local variables Nf, nuf2, tf, and tf2 serve the same purpose as
   *   N, nu2, t, and t2 in mapLatLonToXY, but they are computed with respect
   *   to the footpoint latitude phif.
   *
   *   x1frac, x2frac, x2poly, x3poly, etc. are to enhance readability and
   *   to optimize computations.
   *
   */
function mapXYToLatLon (x, y, lambda0, philambda)
{
    var phif, Nf, Nfpow, nuf2, ep2, tf, tf2, tf4, cf;
    var x1frac, x2frac, x3frac, x4frac, x5frac, x6frac, x7frac, x8frac;
    var x2poly, x3poly, x4poly, x5poly, x6poly, x7poly, x8poly;

    /* Get the value of phif, the footpoint latitude. */
    phif = footpointLatitude (y);

    /* Precalculate ep2 */
    ep2 = (Math.pow (sm_a, 2.0) - Math.pow (sm_b, 2.0))
            / Math.pow (sm_b, 2.0);

    /* Precalculate cos (phif) */
    cf = Math.cos (phif);

    /* Precalculate nuf2 */
    nuf2 = ep2 * Math.pow (cf, 2.0);

    /* Precalculate Nf and initialize Nfpow */
    Nf = Math.pow (sm_a, 2.0) / (sm_b * Math.sqrt (1 + nuf2));
    Nfpow = Nf;

    /* Precalculate tf */
    tf = Math.tan (phif);
    tf2 = tf * tf;
    tf4 = tf2 * tf2;

    /* Precalculate fractional coefficients for x**n in the equations
          below to simplify the expressions for latitude and longitude. */
    x1frac = 1.0 / (Nfpow * cf);

    Nfpow *= Nf;   /* now equals Nf**2) */
    x2frac = tf / (2.0 * Nfpow);

    Nfpow *= Nf;   /* now equals Nf**3) */
    x3frac = 1.0 / (6.0 * Nfpow * cf);

    Nfpow *= Nf;   /* now equals Nf**4) */
    x4frac = tf / (24.0 * Nfpow);

    Nfpow *= Nf;   /* now equals Nf**5) */
    x5frac = 1.0 / (120.0 * Nfpow * cf);

    Nfpow *= Nf;   /* now equals Nf**6) */
    x6frac = tf / (720.0 * Nfpow);

    Nfpow *= Nf;   /* now equals Nf**7) */
    x7frac = 1.0 / (5040.0 * Nfpow * cf);

    Nfpow *= Nf;   /* now equals Nf**8) */
    x8frac = tf / (40320.0 * Nfpow);

    /* Precalculate polynomial coefficients for x**n.
          -- x**1 does not have a polynomial coefficient. */
    x2poly = -1.0 - nuf2;

    x3poly = -1.0 - 2 * tf2 - nuf2;

    x4poly = 5.0 + 3.0 * tf2 + 6.0 * nuf2 - 6.0 * tf2 * nuf2
            - 3.0 * (nuf2 *nuf2) - 9.0 * tf2 * (nuf2 * nuf2);

    x5poly = 5.0 + 28.0 * tf2 + 24.0 * tf4 + 6.0 * nuf2 + 8.0 * tf2 * nuf2;

    x6poly = -61.0 - 90.0 * tf2 - 45.0 * tf4 - 107.0 * nuf2
            + 162.0 * tf2 * nuf2;

    x7poly = -61.0 - 662.0 * tf2 - 1320.0 * tf4 - 720.0 * (tf4 * tf2);

    x8poly = 1385.0 + 3633.0 * tf2 + 4095.0 * tf4 + 1575 * (tf4 * tf2);

    /* Calculate latitude */
    philambda[0] = phif + x2frac * x2poly * (x * x)
            + x4frac * x4poly * Math.pow (x, 4.0)
            + x6frac * x6poly * Math.pow (x, 6.0)
            + x8frac * x8poly * Math.pow (x, 8.0);

    /* Calculate longitude */
    philambda[1] = lambda0 + x1frac * x
            + x3frac * x3poly * Math.pow (x, 3.0)
            + x5frac * x5poly * Math.pow (x, 5.0)
            + x7frac * x7poly * Math.pow (x, 7.0);

    return;
}




/*
   * latLonToUTMXY
   *
   * Converts a latitude/longitude pair to x and y coordinates in the
   * Universal Transverse Mercator projection.
   *
   * Inputs:
   *   lat - Latitude of the point, in radians.
   *   lon - Longitude of the point, in radians.
   *   zone - UTM zone to be used for calculating values for x and y.
   *          If zone is less than 1 or greater than 60, the routine
   *          will determine the appropriate zone from the value of lon.
   *
   * Outputs:
   *   xy - A 2-element array where the UTM x and y values will be stored.
   *
   * Returns:
   *   The UTM zone used for calculating the values of x and y.
   *
   */
function latLonToUTMXY (lat, lon, zone, xy)
{
    mapLatLonToXY (lat, lon, utmCentralMeridian  (zone), xy);

    /* Adjust easting and northing for UTM system. */
    xy[0] = xy[0] * UTMScaleFactor + 500000.0;
    xy[1] = xy[1] * UTMScaleFactor;
    if (xy[1] < 0.0)
        xy[1] = xy[1] + 10000000.0;

    return zone;
}



/*
   * utmXYToLatLon
   *
   * Converts x and y coordinates in the Universal Transverse Mercator
   * projection to a latitude/longitude pair.
   *
   * Inputs:
   *	x - The easting of the point, in meters.
   *	y - The northing of the point, in meters.
   *	zone - The UTM zone in which the point lies.
   *	southhemi - True if the point is in the southern hemisphere;
   *               false otherwise.
   *
   * Returns:
   *	latlon - A 2-element array containing the latitude and
   *            longitude of the point, in radians.
   *
   */
function utmXYToLatLon (x, y, zone, southhemi)
{

    var latlon = [0, 0]
    var cmeridian;

    x -= 500000.0;
    x /= UTMScaleFactor;

    /* If in southern hemisphere, adjust y accordingly. */
    if (southhemi)
        y -= 10000000.0;

    y /= UTMScaleFactor;

    cmeridian = utmCentralMeridian  (zone);
    mapXYToLatLon (x, y, cmeridian, latlon);

    return latlon;

}


function arrayFromMask (nMask) {
    // nMask must be between -2147483648 and 2147483647
    if (nMask > 0x7fffffff || nMask < -0x80000000) { throw new TypeError("arrayFromMask - out of range"); }
    for (var nShifted = nMask, aFromMask = []; nShifted; aFromMask.push(Boolean(nShifted & 1)), nShifted >>>= 1);
    return aFromMask;
}

function basename(path) {
    return String(path).replace(/.*\/|\.[^.]*$/g, '');
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
    return i;
}

function getFlagsByIndex(flag_index, value) {
    var mask = (0x1 << flag_index);
    return ((value & mask) == mask);
}

function addSlashes(input) {
    return String(input).replace(/\\/g, '\\\\').replace(/"/g, '\\"');
}





function getPolyByCid(cid, poly) {
    for (var i = 0; i < poly.length; i++) {
        var item = poly[i];
        if (item.cid == cid) {
            return item;
        }
    }
}
