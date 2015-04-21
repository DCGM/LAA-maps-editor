import QtQuick 2.2
import "functions.js" as F
import cz.mlich 1.0

Rectangle {
    id: pinchmap;
    property bool mapTileVisible:true;
    property bool airspaceVisible: true;

    property real zoomLevel: 7;
    property int zoomLevelInt: Math.floor(zoomLevel);
    property real zoomLevelReminder: zoomLevel - zoomLevelInt
    property int oldZoomLevel: 99
    property int maxZoomLevel: 19;
    property int minZoomLevel: 2;
    property int minZoomLevelShowGeocaches: 9;
    property real tileScaleFactor: 2
    property int tileSize: (128 + (128 * zoomLevelReminder)) * tileScaleFactor;
    property int cornerTileX: 32;
    property int cornerTileY: 32;
    property int numTilesX: Math.ceil(width/tileSize) + 2;
    property int numTilesY: Math.ceil(height/tileSize) + 2;
    property int maxTileNo: Math.pow(2, zoomLevelInt) - 1;
    property bool showTargetIndicator: false
    property double showTargetAtLat: 0;
    property double showTargetAtLon: 0;


    property alias currentPositionShow: positionIndicator.visible
    property int currentPositionIndex: 0
    property double currentPositionLat: 0
    property double currentPositionLon: 0
    property double currentPositionAzimuth: 0;
    property double currentPositionAltitude: 0;
    property string currentPositionTime

    property bool rotationEnabled: true

    property bool pageActive: true;

    property double latitude: 49.803575
    property double longitude: 15.475555
    property variant scaleBarLength: getScaleBarLength(latitude);
    property variant gpsModel;
    property variant trackModel;
    property int pointsSelectedPid;
    property int pointsSelectedIndex: -1;
    property double pointsSelectedLat;
    property double pointsSelectedLon;
    property int polySelectedCid
    property int tracksSelectedTid;
    property int pointSnap: -1;
    signal pointselectedFromMap(int pid);
    signal pointMovedFromMap(variant new_point)
    signal connComputedData(variant connInfo);
    signal tpiComputedData(variant tpi)

    property alias angle: rot.angle

    property bool showRuler: false
    property real rulerDistance: -1;
    property bool autocenter: true;

    property string url;
    // : "~/Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"
    // url: "http://a.tile.openstreetmap.org/%(zoom)d/%(x)d/%(y)d.png";


    //    property alias wfImageSource: worldFileImage.source
    //    property alias wfParam: worldFileImage.param
    //    property alias wfZone: worldFileImage.zone
    //    property alias wfNorthHemi: worldFileImage.northHemi
    property bool wfVisible: false;

    property variant wfcoords;
    property variant polygonCache;
    property variant worldfiles;

    property int earthRadius: 6371000

    //    property alias model: geocacheDisplay.model
    //    property alias waypointModel: waypointDisplay.model
    
    //property int status: PageStatus.active
    //property bool pageActive: (status == PageStatus.active);
    
    property bool needsUpdate: false

    property int filterCupData: 0
    property int filterCupCategory: 0

    property bool showTrackAnyway: true;


    signal pannedManually
    signal trackRendered();
    signal trackInBounds();

    transform: Rotation {
        angle: 0
        origin.x: pinchmap.width/2
        origin.y: pinchmap.height/2
        id: rot
    }

    onShowTrackAnywayChanged: {
        canvas.requestPaint();
    }

    onPointsSelectedPidChanged: {


        if ((trackModel === undefined) || (trackModel.points === undefined)) {
            return;
        }

        var item = getPtByPid(pointsSelectedPid, trackModel.points)

        if (item !== undefined) {
            pointsSelectedLat = item.lat
            pointsSelectedLon = item.lon;

            if (!autocenter || (filterCupData !== 0)) {
                return;
            }
            setCenterLatLon(item.lat, item.lon)
        }

    }

    onTracksSelectedTidChanged: {

        if ((trackModel === undefined) || (trackModel.tracks === undefined) || (!autocenter) || (filterCupData !== 2)) {
            canvas.requestPaint();
            return;
        }

        var points = trackModel.points;

        var tracks = trackModel.tracks[filterCupCategory];
        if (tracks === undefined) {
            return;
        }

        var conns = tracks.conn;
        if (conns === undefined) {
            return;
        }

        for (var i = 0; i < conns.length; i++) {
            var conn = conns[i];
            if (conn.tid === tracksSelectedTid) {
                var item = getPtByPid(conn.pid, trackModel.points)
                if (item !== undefined) {
                    setCenterLatLon(item.lat, item.lon)
                }

            }
        }
    }


    onPolySelectedCidChanged: {
        if (!pageActive) {
            needsUpdate = true;
        } else {
            canvas.requestPaint()
        }
    }

    onFilterCupCategoryChanged: {
        if (!pageActive) {
            needsUpdate = true;
        } else {
            canvas.requestPaint()
        }
    }
    onFilterCupDataChanged: {
        if (!pageActive) {
            needsUpdate = true;
        } else {
            canvas.requestPaint()
        }
    }

    function pointsInBounds() {

        if ((trackModel === undefined) || (trackModel.points === undefined)) {
            return;
        }

        var points = trackModel.points;

        if (points.length <= 1) { // we need at least two points
            return;
        }

        var min_lat, max_lat, min_lon, max_lon;
        var p = points[0];
        var plat = parseFloat(p.lat)
        var plon = parseFloat(p.lon)
        min_lat = plat;
        max_lat = plat;
        min_lon = plon;
        max_lon = plon;

        for (var i = 1; i < points.length; i++) {
            p = points[i]
            plat = parseFloat(p.lat)
            plon = parseFloat(p.lon)
            if (plat > max_lat) {
                max_lat = plat
            }
            if (plat < min_lat) {
                min_lat = plat
            }

            if (plon > max_lon) {
                max_lon = plon
            }
            if (plon < min_lon) {
                min_lon = plon
            }
        }

        zoomToBounds(min_lat, min_lon, max_lat, max_lon)

    }

    onMaxZoomLevelChanged: {
        if (pinchmap.maxZoomLevel < pinchmap.zoomLevel) {
            setZoomLevel(maxZoomLevel);
        }
    }

    onPageActiveChanged:  {
        if (pageActive && needsUpdate) {
            needsUpdate = false;
            pinchmap.setCenterLatLon(pinchmap.latitude, pinchmap.longitude);
            canvas.requestPaint()
        }
    }
    
    onWidthChanged: {
        if (!pageActive) {
            needsUpdate = true;
        } else {
            pinchmap.setCenterLatLon(pinchmap.latitude, pinchmap.longitude);
        }
    }

    onHeightChanged: {
        if (!pageActive) {
            needsUpdate = true;
        } else {
            pinchmap.setCenterLatLon(pinchmap.latitude, pinchmap.longitude);
        }
    }


    onMapTileVisibleChanged: {
        if (!pageActive) {
            needsUpdate = true;
        } else {
            canvas.requestPaint()
        }
    }
    onAirspaceVisibleChanged: {
        if (!pageActive) {
            needsUpdate = true;
        } else {
            canvas.requestPaint()
        }
    }

    onShowTargetAtLatChanged: {
        if (!pageActive) {
            needsUpdate = true;
        } else {
            canvas.requestPaint()
        }
    }

    onCurrentPositionIndexChanged: {
        refreshGPSModelCurrentPosition();
    }

    function refreshGPSModelCurrentPosition() {
        if ((gpsModel !== undefined) && (gpsModel.count < 2)) {
            return;
        }
        var item = gpsModel.get(currentPositionIndex);
        var nextItem = gpsModel.get((currentPositionIndex+1)%gpsModel.count);
        if (item.valid === "true") {
            currentPositionLat = item.lat;
            currentPositionLon = item.lon;
            currentPositionTime = item.time;
            currentPositionAltitude = item.alt;
            currentPositionAzimuth = F.getBearingTo(item.lat, item.lon, nextItem.lat, nextItem.lon)
        }
    }

    onGpsModelChanged: {
        currentPositionIndex = 0
    }

    onTrackModelChanged: {
        if (trackModel === undefined) {
            return;
        }
        if (trackModel.points === undefined) {
            return;
        }

        var points = trackModel.points
        pointsListModel.clear();
        for (var i = 0; i < points.length; i++) {
            var p = points[i];
            pointsListModel.append({
                                       "lat" : parseFloat(p.lat),
                                       "lon" : parseFloat(p.lon),
                                       "pid" : p.pid,
                                       "name": p.name
                                   })

        }
    }


    function setZoomLevel(z) {
        setZoomLevelPoint(z, pinchmap.width/2, pinchmap.height/2);
    }

    function zoomIn() {
        setZoomLevel(pinchmap.zoomLevel + 1)
    }

    function zoomOut() {
        setZoomLevel(pinchmap.zoomLevel - 1)
    }

    function setZoomLevelPoint(z, x, y) {
        if (z === zoomLevel) {
            return;
        }
        if (z < pinchmap.minZoomLevel || z > pinchmap.maxZoomLevel) {
            return;
        }
        var p = getCoordFromScreenpoint(x, y);
        zoomLevel = z;
        setCoord(p, x, y);
    }

    function pan(dx, dy) {
        map.offsetX -= dx;
        map.offsetY -= dy;
    }

    function panEnd() {
        var changed = false;
        var threshold = pinchmap.tileSize;

        while (map.offsetX < -threshold) {
            map.offsetX += threshold;
            cornerTileX += 1;
            changed = true;
        }
        while (map.offsetX > threshold) {
            map.offsetX -= threshold;
            cornerTileX -= 1;
            changed = true;
        }

        while (map.offsetY < -threshold) {
            map.offsetY += threshold;
            cornerTileY += 1;
            changed = true;
        }
        while (map.offsetY > threshold) {
            map.offsetY -= threshold;
            cornerTileY -= 1;
            changed = true;
        }
        updateCenter();
    }

    function zoomToBounds(lat1, lon1, lat2, lon2) {

        if ((pinchmap.width <= 0) || (pinchmap.height <= 0)) {
            return;
        }

        console.log("zoomToBoundsB: " + pinchmap.width + " " + pinchmap.height +  " " + tileSize)

        setCenterLatLon(0.5*(lat1+lat2), 0.5*(lon1+lon2))

        var latFrac = Math.abs(deg2rad(lat1) - deg2rad(lat2))/Math.PI
        var lonFrac = Math.abs(lon1 - lon2) / 360;

        var latZoom = Math.floor(Math.log( pinchmap.height / tileSize / latFrac) / Math.log(2) );
        var lonZoom = Math.floor(Math.log( pinchmap.width  / tileSize / lonFrac) / Math.log(2) );

        console.log("zoomToBoundsC:" +latFrac + " " + lonFrac + " " + latZoom + " " + lonZoom)

        setZoomLevel(Math.min(latZoom,lonZoom, maxZoomLevel));
        trackInBounds();
    }

    function updateCenter() {
        var l = getCenter()
        longitude = l[1]
        latitude = l[0]
        updateGeocaches();
    }

    function requestUpdate() {
        var start = getCoordFromScreenpoint(0,0)
        var end = getCoordFromScreenpoint(pinchmap.width,pinchmap.height)
        //         controller.updateGeocaches(start[0], start[1], end[0], end[1])
        updateGeocaches()
        console.debug("Update requested.")
    }

    function requestUpdateDetails() {
        var start = getCoordFromScreenpoint(0,0)
        var end = getCoordFromScreenpoint(pinchmap.width,pinchmap.height)
        //        controller.downloadGeocaches(start[0], start[1], end[0], end[1])
        console.debug("Download requested.")
    }

    function getScaleBarLength(lat) {
        var destlength = width/5;
        var mpp = getMetersPerPixel(lat);
        var guess = mpp * destlength;
        var base = 10 * -Math.floor(Math.log(guess)/Math.log(10) + 0.00001)
        var length_meters = Math.round(guess/base)*base
        var length_pixels = length_meters / mpp
        return [length_pixels, length_meters]
    }

    function getMetersPerPixel(lat) {
        return Math.cos(lat * Math.PI / 180.0) * 2.0 * Math.PI * earthRadius / (256 * (maxTileNo + 1))
    }

    function deg2rad(deg) {
        return deg * (Math.PI /180.0);
    }

    function deg2num(lat, lon) {
        var rad = deg2rad(lat % 90);
        var n = maxTileNo + 1;
        var xtile = ((lon % 180.0) + 180.0) / 360.0 * n;
        var ytile = (1.0 - Math.log(Math.tan(rad) + (1.0 / Math.cos(rad))) / Math.PI) / 2.0 * n;
        return [xtile, ytile];
    }

    function setLatLon(lat, lon, x, y) {
        var oldCornerTileX = cornerTileX
        var oldCornerTileY = cornerTileY
        var tile = deg2num(lat, lon);
        var cornerTileFloatX = tile[0] + (map.rootX - x) / tileSize // - numTilesX/2.0;
        var cornerTileFloatY = tile[1] + (map.rootY - y) / tileSize // - numTilesY/2.0;
        cornerTileX = Math.floor(cornerTileFloatX);
        cornerTileY = Math.floor(cornerTileFloatY);
        map.offsetX = -(cornerTileFloatX - Math.floor(cornerTileFloatX)) * tileSize;
        map.offsetY = -(cornerTileFloatY - Math.floor(cornerTileFloatY)) * tileSize;
        updateCenter();
    }

    function setCoord(c, x, y) {
        setLatLon(c[0], c[1], x, y);
    }

    function setCenterLatLon(lat, lon) {
        setLatLon(lat, lon, pinchmap.width/2, pinchmap.height/2);
    }

    function setCenterCoord(c) {
        setCenterLatLon(c[0], c[1]);
    }

    function getCoordFromScreenpoint(x, y) {
        var realX = - map.rootX - map.offsetX + x;
        var realY = - map.rootY - map.offsetY + y;
        var realTileX = cornerTileX + realX / tileSize;
        var realTileY = cornerTileY + realY / tileSize;
        return num2deg(realTileX, realTileY);
    }

    function getScreenpointFromCoord(lat, lon) {
        var tile = deg2num(lat, lon)
        var realX = (tile[0] - cornerTileX) * tileSize
        var realY = (tile[1] - cornerTileY) * tileSize
        var x = realX + map.rootX + map.offsetX
        var y = realY + map.rootY + map.offsetY
        return [x, y]
    }

    function getMappointFromCoord(lat, lon) {
        //        console.count()
        var tile = deg2num(lat, lon)
        var realX = (tile[0] - cornerTileX) * tileSize
        var realY = (tile[1] - cornerTileY) * tileSize
        return [realX, realY]
        
    }

    function getCenter() {
        return getCoordFromScreenpoint(pinchmap.width/2, pinchmap.height/2);
    }

    function sinh(aValue) {
        return (Math.pow(Math.E, aValue)-Math.pow(Math.E, -aValue))/2;
    }

    function num2deg(xtile, ytile) {
        var n = Math.pow(2, zoomLevelInt);
        var lon_deg = xtile / n * 360.0 - 180;
        var lat_rad = Math.atan(sinh(Math.PI * (1 - 2 * ytile / n)));
        var lat_deg = lat_rad * 180.0 / Math.PI;
        return [lat_deg % 90.0, lon_deg % 180.0];
    }

    function tileUrl(tx, ty) {
        if ((url === undefined) || (url === "")) {
            return Qt.resolvedUrl("./data/noimage-disabled.png")
        }

        if (tx < 0 || tx > maxTileNo) {
            return Qt.resolvedUrl("./data/noimage.png")
        }

        if (ty < 0 || ty > maxTileNo) {
            return Qt.resolvedUrl("./data/noimage.png")
        }


        var res = Qt.resolvedUrl(F.getMapTile(url, tx, ty, zoomLevelInt));

        if (filereader.is_local_file(res) && !filereader.file_exists(res)) { // do not open non existing image
            return "";
        }

        return res;

    }

    function imageStatusToString(status) {
        switch (status) {
            //% "Ready"
        case Image.Ready: return qsTrId("pinchmap-ready");
            //% "Not Set"
        case Image.Null: return qsTrId("pinchmap-not-set");
            //% "Error"
        case Image.Error: return qsTrId("pinchmap-error");
            //% "Loading ..."
        case Image.Loading: return qsTrId("pinchmap-loading");
            //% "Unknown error"
        default: return qsTrId("pinchmap-unknown-error");
        }
    }


    //    ColorModification {
    //        id: colorModification
    //    }


    Grid {

        id: map;
        columns: numTilesX;
        width: numTilesX * tileSize;
        height: numTilesY * tileSize;
        property int rootX: -(width - parent.width)/2;
        property int rootY: -(height - parent.height)/2;
        property int offsetX: 0;
        property int offsetY: 0;
        x: rootX + offsetX;
        y: rootY + offsetY;


        Repeater {
            id: tiles


            model: (pinchmap.numTilesX * pinchmap.numTilesY);
            Rectangle {
                id: tile
                property alias source: img.source;
                property int tileX: cornerTileX + (index % numTilesX)
                property int tileY: cornerTileY + Math.floor(index / numTilesX)
                Rectangle {
                    id: progressBar;
                    property real p: 0;
                    height: 16;
                    width: parent.width - 32;
                    anchors.centerIn: img;
                    color: "#c0c0c0";
                    border.width: 1;
                    border.color: "#000000";
                    Rectangle {
                        anchors.left: parent.left;
                        anchors.margins: 2;
                        anchors.top: parent.top;
                        anchors.bottom: parent.bottom;
                        width: (parent.width - 4) * progressBar.p;
                        color: "#000000";
                    }
                    visible: mapTileVisible
                }
                NativeText {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    y: parent.height/2 - 32
                    text: imageStatusToString(img.status)
                    visible: mapTileVisible
                }
                Image {
                    anchors.fill: parent;
                    visible: mapTileVisible && (img.status === Image.Null)
                    source: "./data/noimage.png"
                }


                Image {
                    id: img;
                    anchors.fill: parent;
                    onProgressChanged: { progressBar.p = progress }
                    source: mapTileVisible ? tileUrl(tileX, tileY) : "";
                    visible: mapTileVisible
                }


                width: tileSize;
                height: tileSize;
                color: mapTileVisible ? "#c0c0c0" : "transparent";
            }

        }


    }

    onWorldfilesChanged: {
        worldfilesListModel.clear();
        if (worldfiles !== undefined) {
            for (var i = 0; i < worldfiles.length; i++) {
                var wf = worldfiles[i];

                if (!file_reader.file_exists(Qt.resolvedUrl(wf.gfw))) {
                    continue;
                }
                if (!file_reader.file_exists(Qt.resolvedUrl(wf.image))) {
                    continue;
                }

                var arr = file_reader.read(Qt.resolvedUrl(wf.gfw)).toString().split("\n");

                for (var j = 0; j < arr.length; j++) {
                    arr[j] = parseFloat(arr[j])
                }

                if ((arr[1] !== 0) || (arr[2] !== 0)) {
                    console.log("gfw contains rotation. unsupported" + arr[1] + " " + arr[2])
                }

                //            map.wfParam = arr;
                //            map.wfZone = zone;
                //            map.wfNorthHemi = northHemisphere
                //            map.wfImageSource = gif;

                var newObj = {
                    "imageSource": wf.image,
                    "utmZone": wf.utmZone,
                    "northHemisphere": wf.northHemisphere,
                    "param": JSON.stringify(arr)

                }
                worldfilesListModel.append(newObj);
            }
        }
    }

    ListModel {
        id: worldfilesListModel;
    }

    Repeater {
        model: worldfilesListModel;
        delegate: WorldFileImage {
            zone: model.utmZone;
            northHemi: model.northHemisphere;
            source: model.imageSource;
            param: JSON.parse(model.param);
            visible: wfVisible
        }
    }


    Item {
        visible: (filterCupData < 2)
        Repeater {
            model: pointsListModel;
            delegate:  Waypoint {
                targetPoint: getMappointFromCoord(model.lat, model.lon)
                waypointType: ((model.pid === pointsSelectedPid) && (filterCupData == 0))
                              ? "target-indicator-cross"
                              : "target-indicator-cross-blue"
                mapx: map.x
                mapy: map.y
                z: 2000


//                NativeText {
//                    x: parent.width*0.75
//                    y: parent.height*0.75
//                    text: model.name
//                    visible: (pinchmap.zoomLevel > 9);
//                }

            }

        }
    }

    Image {
        id: targetIndicator
        source: "./data/target-indicator-cross.png"
        property variant t: getMappointFromCoord(showTargetAtLat, showTargetAtLon)
        x: map.x + t[0] - width/2
        y: map.y + t[1] - height/2


        visible: showTargetIndicator
        transform: Rotation {
            id: rotationTarget
            origin.x: targetIndicator.width/2
            origin.y: targetIndicator.height/2
        }
    }


    Waypoint {
        id: positionIndicator
        waypointType: "Airport15"
        targetPoint: getMappointFromCoord(currentPositionLat, currentPositionLon)
        azimuth: currentPositionAzimuth
        mapx: map.x
        mapy: map.y
        visible: false;
    }

    Ruler {
        id: ruler
        mapx: map.x
        mapy: map.y;
        startPoint: getMappointFromCoord(0, 0)
        endPoint:  getMappointFromCoord(0, 0)
    }

    function getPtByPid(pid, points) {
        for (var i = 0; i < points.length; i++) {
            var item = points[i]
            if (item.pid == pid) {
                return item;
            }
        }
    }

    function getPolyByCid(cid, poly) {
        for (var i = 0; i < poly.length; i++) {
            var item = poly[i];
            if (item.cid == cid) {
                return item;
            }
        }
    }

    function getAngleByIdx(idx, trackinfo) {
        for (var i = 0; i < trackinfo.length; i++) {
            var item = trackinfo[i];
            if ((item.idx === idx) && (item.angle !== undefined)) {
                return item.angle;
            }
        }
    }



    function getFlags(current, defaults, flag_index) {
        var mask = (0x1 << flag_index);
        return getFlagsMask(current, defaults, mask);
    }

    function getFlagsMask(current, defaults, mask) {
        if (current < 0) {
            return ((defaults & mask) == mask)
        }
        return ((current & mask) == mask)

    }



    Canvas {
        id: canvas
        x: map.x
        y: map.y
        width: map.width
        height: map.height
        renderStrategy: Canvas.Cooperative
        onPaint: {
            console.time("canvas-onPaint")

            var ctx = canvas.getContext("2d");
            ctx.save();
            ctx.lineCap = "butt"
            ctx.lineJoin = "bevel"
            ctx.lineWidth = 2;
            ctx.clearRect(0, 0, canvas.width, canvas.height)




            var item, i, c, screenPoint;

            //            if (wfcoords !== undefined) {
            //                ctx.strokeStyle="#ff0000"
            //                ctx.beginPath()

            //                item = wfcoords[0]
            //                screenPoint = getMappointFromCoord(item[0], item[1])
            //                ctx.moveTo(screenPoint[0], screenPoint[1])
            //                for (i = 1; i < wfcoords.length; i++) {
            //                    item = wfcoords[i];
            //                    screenPoint = getMappointFromCoord(item[0], item[1])
            //                    ctx.lineTo(screenPoint[0], screenPoint[1])
            //                }
            //                ctx.stroke();

            //            }


            if (trackModel === undefined ) {
                return;
            }

            if (filterCupData < 2) { // 0 , 1 == Tab(points, polygons)

                // draw points -> points are drawed as an Images


                // draw polygons
                if (trackModel.poly !== undefined) {
                    var poly = trackModel.poly;
                    if (poly[0] !== undefined) {
                        for (i = 0; i < poly.length; i++) {
                            var polygon = poly[i]
                            if (polygon.points !== undefined && polygon.points.length > 1) {

                                ctx.strokeStyle="#"+ polygon.color;
                                ctx.lineWidth = ((filterCupData == 1) && (polySelectedCid === polygon.cid)) ? 4 : 2;
                                ctx.beginPath()

                                var geom_points = polygon.points;
                                item = geom_points[0];
                                screenPoint = getMappointFromCoord(item.lat, item.lon)
                                ctx.moveTo(screenPoint[0], screenPoint[1])

                                for (var j = 1; j < geom_points.length; j++) {
                                    item = geom_points[j];
                                    screenPoint = getMappointFromCoord(item.lat, item.lon)
                                    ctx.lineTo(screenPoint[0], screenPoint[1])

                                }
                                ctx.stroke();
                                //complexityCounter++;
                            }

                        }
                    }
                }



            }

            polygonCache = [];

            if ((filterCupData === 2) || showTrackAnyway) { // Tab(tracks)
                var tracks = trackModel.tracks[filterCupCategory];
                var points = trackModel.points;
                var poly = trackModel.poly;
                var conns = tracks.conn;
                var enabledPoly = tracks.poly;
                var snapDistance = 100000;
                var snapLat = 0;
                var snapLon = 0;

                var trackInfo = [];
                var polygonCachePoints = [];

                // draw connection for selected category
                if ((conns !== undefined) && conns.length > 0) {

                    // draw track polygon
                    var c = conns[0];

                    ctx.strokeStyle= "#cc00cc"
                    ctx.lineWidth = 2;

                    ctx.beginPath()


                    if (pointSnap >= 0) {
                        var item = getPtByPid(pointSnap, points);
                        if (item !== undefined) {
                            snapLat = item.lat;
                            snapLon = item.lon;
                        }
                    }

                    var item = getPtByPid(c.pid, points);
                    if (item !== undefined) {
                        screenPoint = getMappointFromCoord(item.lat, item.lon)
                        ctx.moveTo(screenPoint[0], screenPoint[1])
                        polygonCachePoints.push({"lat": item.lat, "lon": item.lon})
                    }

                    var prevItem = item;

                    if (conns.length >= 2) {
                        var c = conns[1];
                        var item = getPtByPid(c.pid, points);

                        var angle = -1;
                        switch (c.type) {
                        case "none":
                        case "line":
                            angle = ((F.getBearingTo(prevItem.lat, prevItem.lon, item.lat, item.lon)+90)%360);

                            break;
                        case "polyline":
                            var selPoly = getPolyByCid(c.ptr, poly);
                            if (selPoly === undefined) {
                                angle = ((F.getBearingTo(prevItem.lat, prevItem.lon, item.lat, item.lon)+90)%360);
                            } else {
                                var selPolyPoint = selPoly.points[0]
                                angle = ((F.getBearingTo(prevItem.lat, prevItem.lon, selPolyPoint.lat, selPolyPoint.lon)+90)%360);
                            }
                            break;
                        case "arc1":
                        case "arc2":

                            var cw = (c.type === "arc1")
                            var center = getPtByPid(c.ptr, points);
                            if (center !== undefined) {

                                var tmp = F.insertMidArc(center.lat, center.lon, item.lat, item.lon, prevItem.lat, prevItem.lon, cw);

                                if (tmp.length > 2) {
                                    var tmpFirst = tmp[0];
                                    var tmpLast = tmp[tmp.length-1];
                                    var firstDistance = F.getDistanceTo(tmpFirst[0], tmpFirst[1], item.lat, item.lon);
                                    var lastDistance = F.getDistanceTo(tmpLast[0], tmpLast[1], item.lat, item.lon);

                                    if (firstDistance > lastDistance) {
                                        angle = ((F.getBearingTo(prevItem.lat, prevItem.lon, tmpFirst[0], tmpFirst[1])+90)%360);
                                    } else {
                                        angle = ((F.getBearingTo(prevItem.lat, prevItem.lon, tmpLast[0], tmpLast[1])+90)%360);

                                    }
                                }

                            }
                            break;
                        }

                        trackInfo.push({
                                           "idx": 0,
                                           "distance": 0
                                       });

                        trackInfo.push({
                                           "idx": 0,
                                           "angle": angle
                                       });
                    }


                    for (var i = 1; i < conns.length; i++) {
                        var c = conns[i];
                        var item = getPtByPid(c.pid, points);
                        if (item === undefined) {
                            continue;
                        }

                        screenPoint = getMappointFromCoord(item.lat, item.lon)
                        var distance = F.getDistanceTo(item.lat, item.lon, prevItem.lat, prevItem.lon);
                        var angle = ((F.getBearingTo(prevItem.lat, prevItem.lon, item.lat, item.lon)+90)%360);

                        polygonCachePoints.push({"lat": prevItem.lat, "lon": prevItem.lon})


                        switch (c.type) {
                        case "none":
                            ctx.moveTo(screenPoint[0], screenPoint[1])
                            //                            polygonCachePoints.push({"lat": item.lat, "lon": item.lon})
                            break;
                        case "line":
                            ctx.lineTo(screenPoint[0], screenPoint[1])

                            if (pointSnap >= 0) {
                                var projPoint = F.projectionPointToLineLatLon(prevItem.lat, prevItem.lon, item.lat, item.lon, pointsSelectedLat, pointsSelectedLon)
                                var tmpDistance = F.getDistanceTo(pointsSelectedLat, pointsSelectedLon, projPoint[0], projPoint[1])
                                if (tmpDistance < snapDistance) {
                                    snapDistance = tmpDistance;
                                    snapLat = projPoint[0];
                                    snapLon = projPoint[1];
                                }
                            }

                            polygonCachePoints.push({"lat": item.lat, "lon": item.lon})

                            break;
                        case "polyline":
                            distance = 0;

                            var selPoly = getPolyByCid(c.ptr, poly);
                            if (selPoly === undefined) {
                                ctx.moveTo(screenPoint[0], screenPoint[1])
                            } else {
                                var selPolyPoints = selPoly.points
                                var prevPolyItem = {
                                    "lat": prevItem.lat,
                                    "lon": prevItem.lon
                                }


                                for (var k = 0; k < selPolyPoints.length; k++) {
                                    var selPolyItem = selPolyPoints[k];
                                    var screenPoint2 = getMappointFromCoord(selPolyItem.lat, selPolyItem.lon)
                                    ctx.lineTo(screenPoint2[0], screenPoint2[1])
                                    polygonCachePoints.push({"lat": selPolyItem.lat, "lon": selPolyItem.lon})
                                    distance = distance + F.getDistanceTo(selPolyItem.lat, selPolyItem.lon, prevPolyItem.lat, prevPolyItem.lon);


                                    if (pointSnap >= 0) {
                                        var projPoint = F.projectionPointToLineLatLon(prevPolyItem.lat, prevPolyItem.lon, selPolyItem.lat, selPolyItem.lon, pointsSelectedLat, pointsSelectedLon)
                                        var tmpDistance = F.getDistanceTo(pointsSelectedLat, pointsSelectedLon, projPoint[0], projPoint[1])
                                        if (tmpDistance < snapDistance) {
                                            snapDistance = tmpDistance;
                                            snapLat = projPoint[0];
                                            snapLon = projPoint[1];
                                        }
                                    }


                                    prevPolyItem = selPolyItem;
                                }
                                distance = distance + F.getDistanceTo(prevPolyItem.lat, prevPolyItem.lon, item.lat, item.lon)
                                angle = ((F.getBearingTo(prevPolyItem.lat, prevPolyItem.lon, item.lat, item.lon)+90)%360);

                                ctx.lineTo(screenPoint[0], screenPoint[1])
                                polygonCachePoints.push({"lat": item.lat, "lon": item.lon})

                            }

                            break;
                        case "arc1":
                        case "arc2":

                            distance = 0;
                            var prevArcItem = [prevItem.lat,prevItem.lon];


                            var tmpArray = []

                            var cw = (c.type === "arc1")
                            var center = getPtByPid(c.ptr, points);
                            if (center === undefined) {
                                ctx.moveTo(screenPoint[0], screenPoint[1])
                            } else {

                                var tmp = F.insertMidArc(center.lat, center.lon, item.lat, item.lon, prevItem.lat, prevItem.lon, cw);
                                if (tmp.length > 2) {
                                    var tmpFirst = tmp[0];
                                    var tmpLast = tmp[tmp.length-1];
                                    var firstDistance = F.getDistanceTo(tmpFirst[0], tmpFirst[1], item.lat, item.lon);
                                    var lastDistance = F.getDistanceTo(tmpLast[0], tmpLast[1], item.lat, item.lon);

                                    if (firstDistance > lastDistance) {
                                        for (var k = 0; k < tmp.length; k++) {
                                            var arcItem = tmp[k]
                                            var screenPoint2 = getMappointFromCoord(arcItem[0], arcItem[1]);
                                            distance = distance + F.getDistanceTo(arcItem[0], arcItem[1], prevArcItem[0], prevArcItem[1]);

                                            ctx.lineTo(screenPoint2[0], screenPoint2[1])
                                            polygonCachePoints.push({"lat": arcItem[0], "lon": arcItem[1]})


                                            if (pointSnap >= 0) {
                                                var projPoint = F.projectionPointToLineLatLon(prevArcItem[0], prevArcItem[1], arcItem[0], arcItem[1], pointsSelectedLat, pointsSelectedLon)
                                                var tmpDistance = F.getDistanceTo(pointsSelectedLat, pointsSelectedLon, projPoint[0], projPoint[1])
                                                if (tmpDistance < snapDistance) {
                                                    snapDistance = tmpDistance;
                                                    snapLat = projPoint[0];
                                                    snapLon = projPoint[1];
                                                }
                                            }

                                            prevArcItem = arcItem
                                        }
                                    } else {
                                        for (var k = tmp.length-1; k >=0; k--) {
                                            var arcItem = tmp[k]
                                            var screenPoint2 = getMappointFromCoord(arcItem[0], arcItem[1]);
                                            distance = distance + F.getDistanceTo(arcItem[0], arcItem[1], prevArcItem[0], prevArcItem[1]);
                                            ctx.lineTo(screenPoint2[0], screenPoint2[1])
                                            polygonCachePoints.push({"lat": arcItem[0], "lon": arcItem[1]})

                                            if (pointSnap >= 0) {
                                                var projPoint = F.projectionPointToLineLatLon(prevArcItem[0], prevArcItem[1], arcItem[0], arcItem[1], pointsSelectedLat, pointsSelectedLon)
                                                var tmpDistance = F.getDistanceTo(pointsSelectedLat, pointsSelectedLon, projPoint[0], projPoint[1])
                                                if (tmpDistance < snapDistance) {
                                                    snapDistance = tmpDistance;
                                                    snapLat = projPoint[0];
                                                    snapLon = projPoint[1];
                                                }
                                            }

                                            prevArcItem = arcItem
                                        }
                                    }

                                    angle = ((F.getBearingTo(prevArcItem[0], prevArcItem[1], item.lat, item.lon)+90)%360);
                                    distance = distance + F.getDistanceTo(item.lat, item.lon, prevArcItem[0], prevArcItem[1]);

                                    ctx.lineTo(screenPoint[0], screenPoint[1])
                                    polygonCachePoints.push({"lat": item.lat, "lon": item.lon})



                                    // draw center of arc (500 meters to each side)
                                    var tmp = F.getCoordByDistanceBearing(F.global_center_lat, F.global_center_lon,45, 500)
                                    var screenPoint2 = getMappointFromCoord(tmp.lat, tmp.lon)
                                    ctx.moveTo (screenPoint2[0], screenPoint2[1]);
                                    var tmp = F.getCoordByDistanceBearing(F.global_center_lat, F.global_center_lon,225, 500)
                                    var screenPoint2 = getMappointFromCoord(tmp.lat, tmp.lon)
                                    ctx.lineTo (screenPoint2[0], screenPoint2[1]);
                                    var tmp = F.getCoordByDistanceBearing(F.global_center_lat, F.global_center_lon,135, 500)
                                    var screenPoint2 = getMappointFromCoord(tmp.lat, tmp.lon)
                                    ctx.moveTo (screenPoint2[0], screenPoint2[1]);
                                    var tmp = F.getCoordByDistanceBearing(F.global_center_lat, F.global_center_lon,315, 500)
                                    var screenPoint2 = getMappointFromCoord(tmp.lat, tmp.lon)
                                    ctx.lineTo (screenPoint2[0], screenPoint2[1]);



                                    if (pointSnap >= 0) {
                                        var tmpDistance = F.getDistanceTo(pointsSelectedLat, pointsSelectedLon, F.global_center_lat, F.global_center_lon)
                                        if (tmpDistance < snapDistance) {
                                            snapDistance = tmpDistance;
                                            snapLat = F.global_center_lat;
                                            snapLon = F.global_center_lon;
                                        }
                                    }


                                }
                                ctx.moveTo(screenPoint[0], screenPoint[1])

                            }

                            break;
                        case "arc3":
                        case "arc4":
                            console.log("Not implemented")
                            ctx.moveTo(screenPoint[0], screenPoint[1])
                            break;
                        }

                        trackInfo.push({
                                           "idx": i,
                                           "distance": distance
                                       });

                        trackInfo.push({
                                           "idx": i,
                                           "angle": angle
                                       });

                        //                        console.log("distance " + i +": " + distance);

                        prevItem = item;

                        var tmp = [];
                        tmp = polygonCache
                        tmp.push({
                                     "cid": 1,
                                     "name": "polygon",
                                     "color": "cc00cc",
                                     "points": polygonCachePoints
                                 });
                        polygonCache = tmp
                        polygonCachePoints =[];

                    }

                    ctx.stroke();

                    if (pointSnap >= 0) {


                        for (var i = 0; i < pointsListModel.count; i++) {
                            var item = pointsListModel.get(i);
                            if (item.pid === pointSnap) {
                                pointsSelectedIndex = i;
                                break;
                            }
                        }

                        pointsListModel.setProperty(pointsSelectedIndex, "lat", snapLat);
                        pointsListModel.setProperty(pointsSelectedIndex, "lon", snapLon);

                        pointMovedFromMap({
                                              "pid" : pointSnap,
                                              "lat": snapLat,
                                              "lon": snapLon
                                          });
                        pointSnap = -1;

                    }



                    /////////////// turn points and time gates
                    ctx.beginPath()
                    var c = conns[0];
                    var item = getPtByPid(c.pid, points);
                    var prevItem = item;

                    var tp_enabled = getFlags(c.flags, tracks.default_flags, 0)
                    var radius = (c.radius < 0) ? tracks.default_radius : c.radius;



                    if (tp_enabled) {
                        // kruznice
                        ctx.strokeStyle= ((filterCupData === 2) && (tracksSelectedTid === c.tid)) ? "#cc0000" : "#0000cc"
                        ctx.beginPath();

                        var tmp = polygonCache;
                        var tmp_points = F.insertMidArcByAngle(item.lat, item.lon, 0, Math.PI*2, true, F.distToAngle(radius));
                        var points_ll = [];
                        var arcPoint = tmp_points[0]
                        var screenPoint3 = getMappointFromCoord(arcPoint[0],arcPoint[1])
                        ctx.lineTo(screenPoint3[0], screenPoint3[1])
                        points_ll.push({"lat": arcPoint[0], "lon": arcPoint[1]})
                        for (var k = 1; k < tmp_points.length; k++) {
                            var arcPoint = tmp_points[k];
                            points_ll.push({"lat": arcPoint[0], "lon": arcPoint[1]})
                            var screenPoint3 = getMappointFromCoord(arcPoint[0],arcPoint[1])
                            ctx.lineTo(screenPoint3[0], screenPoint3[1])
                        }
                        var arcPoint = tmp_points[0]
                        points_ll.push({"lat": arcPoint[0], "lon": arcPoint[1]})
                        var screenPoint3 = getMappointFromCoord(arcPoint[0],arcPoint[1])
                        ctx.lineTo(screenPoint3[0], screenPoint3[1])

                        ctx.stroke();

                        tmp.push({
                                     "cid": 1,
                                     "name": "turn point circle",
                                     "color": "0000ff",
                                     "points": points_ll
                                 });
                        polygonCache = tmp;

                    }

                    if (conns.length >= 2) {
                        var c2 = conns[1];
                        item = getPtByPid(c2.pid, points);

                        var show_gate = (c.flags > 1)
                        if (c.flags < 0) {
                            show_gate = (tracks.default_flags > 1)
                        }

                        if (show_gate) {
                            //                        var tg_enabled = getFlags(c.flags, tracks.default_flags, 1);
                            //                        var sg_enabled = getFlags(c.flags, tracks.default_flags, 2);
                            //                        if (tg_enabled || sg_enabled) {

                            var angle = c.angle;

                            if (angle < 0) {
                                angle = c.computed_angle
                                var tmpAngle = getAngleByIdx(0, trackInfo);
                                if (tmpAngle !== undefined) {
                                    angle = tmpAngle
                                }
                            }

                            var gateA = F.getCoordByDistanceBearing(prevItem.lat, prevItem.lon, (angle)%360, radius)
                            var gateB = F.getCoordByDistanceBearing(prevItem.lat, prevItem.lon, (180+angle)%360, radius)
                            var gateC = F.getCoordByDistanceBearing(prevItem.lat, prevItem.lon, (270+angle)%360, 0.2*radius)
                            var screenPointGA = getMappointFromCoord(gateA.lat, gateA.lon)
                            var screenPointGB = getMappointFromCoord(gateB.lat, gateB.lon)
                            var screenPointGC = getMappointFromCoord(gateC.lat, gateC.lon)

                            var tmp = polygonCache;
                            tmp.push({
                                         "cid": 1,
                                         "name": "gate",
                                         "color": "0000ff",
                                         "points": [
                                             {"lat": gateA.lat, "lon": gateA.lon},
                                             {"lat": gateB.lat, "lon": gateB.lon},
                                             {"lat": gateC.lat, "lon": gateC.lon},
                                             {"lat": gateA.lat, "lon": gateA.lon}
                                         ]
                                     });
                            polygonCache = tmp;

                            ctx.strokeStyle= ((filterCupData === 2) && (tracksSelectedTid === c.tid)) ? "#cc0000" : "#0000cc"

                            ctx.beginPath();
                            ctx.moveTo(screenPointGA[0], screenPointGA[1])
                            ctx.lineTo(screenPointGB[0], screenPointGB[1])
                            ctx.lineTo(screenPointGC[0], screenPointGC[1])
                            ctx.lineTo(screenPointGA[0], screenPointGA[1])
                            ctx.stroke();






                        }



                        for (var i = 1; i < conns.length; i++) {
                            var c = conns[i];
                            var item = getPtByPid(c.pid, points);

                            var tp_enabled = getFlags(c.flags, tracks.default_flags, 0)
                            //                            var tg_enabled = getFlags(c.flags, tracks.default_flags, 1)
                            //                            var sg_enabled = getFlags(c.flags, tracks.default_flags, 2)
                            var radius = (c.radius < 0) ? tracks.default_radius : c.radius;
                            var prev = conns[i-1];
                            var prevItem = getPtByPid(prev.pid, points)


                            if (tp_enabled) {
                                // kruznice

                                ctx.strokeStyle= (tracksSelectedTid === c.tid) ? "#cc0000" : "#0000cc"
                                ctx.beginPath();

                                var tmp = polygonCache;
                                var tmp_points = F.insertMidArcByAngle(item.lat, item.lon, 0, Math.PI*2, true, F.distToAngle(radius));
                                var points_ll = [];
                                var arcPoint = tmp_points[0]
                                points_ll.push({"lat": arcPoint[0], "lon": arcPoint[1]})
                                var screenPoint3 = getMappointFromCoord(arcPoint[0],arcPoint[1])
                                ctx.lineTo(screenPoint3[0], screenPoint3[1])
                                for (var k = 1; k < tmp_points.length; k++) {
                                    var arcPoint = tmp_points[k];
                                    points_ll.push({"lat": arcPoint[0], "lon": arcPoint[1]})
                                    var screenPoint3 = getMappointFromCoord(arcPoint[0],arcPoint[1])
                                    ctx.lineTo(screenPoint3[0], screenPoint3[1])
                                }
                                var arcPoint = tmp_points[0]
                                points_ll.push({"lat": arcPoint[0], "lon": arcPoint[1]})
                                var screenPoint3 = getMappointFromCoord(arcPoint[0],arcPoint[1])
                                ctx.lineTo(screenPoint3[0], screenPoint3[1])

                                ctx.stroke();

                                tmp.push({
                                             "cid": 1,
                                             "name": "turn point circle",
                                             "color": "0000ff",
                                             "points": points_ll
                                         });
                                polygonCache = tmp;


                            }

                            var show_gate = (c.flags > 1)
                            if (c.flags < 0) {
                                show_gate = (tracks.default_flags > 1)
                            }

                            if (show_gate) {
                                //                            var tg_enabled = getFlags(c.flags, tracks.default_flags, 1);
                                //                            var sg_enabled = getFlags(c.flags, tracks.default_flags, 2);
                                //                            if (tg_enabled || sg_enabled) {
                                var angle = c.angle;

                                if (angle < 0) {
                                    angle = c.computed_angle
                                    var tmpAngle = getAngleByIdx(i, trackInfo);
                                    if (tmpAngle !== undefined) {
                                        angle = tmpAngle
                                    }
                                }

                                var gateA = F.getCoordByDistanceBearing(item.lat, item.lon, (angle)%360, radius)
                                var gateB = F.getCoordByDistanceBearing(item.lat, item.lon, (180+angle)%360, radius)
                                var gateC = F.getCoordByDistanceBearing(item.lat, item.lon, (270+angle)%360, 100)
                                var screenPointGA = getMappointFromCoord(gateA.lat, gateA.lon)
                                var screenPointGB = getMappointFromCoord(gateB.lat, gateB.lon)
                                var screenPointGC = getMappointFromCoord(gateC.lat, gateC.lon)

                                ctx.strokeStyle= (tracksSelectedTid === c.tid) ? "#cc0000" : "#0000cc"

                                ctx.beginPath();
                                ctx.moveTo(screenPointGA[0], screenPointGA[1])
                                ctx.lineTo(screenPointGB[0], screenPointGB[1])
                                ctx.lineTo(screenPointGC[0], screenPointGC[1])
                                ctx.lineTo(screenPointGA[0], screenPointGA[1])
                                ctx.stroke();

                                var tmp = polygonCache;
                                tmp.push({
                                             "cid": 1,
                                             "name": "gate",
                                             "color": "0000ff",
                                             "points": [
                                                 {"lat": gateA.lat, "lon": gateA.lon},
                                                 {"lat": gateB.lat, "lon": gateB.lon},
                                                 {"lat": gateC.lat, "lon": gateC.lon},
                                                 {"lat": gateA.lat, "lon": gateA.lon}
                                             ]
                                         });
                                polygonCache = tmp;





                            }
                            prevItem = item;


                        }
                    }

                    connComputedData(trackInfo)

                    ctx.stroke()



                }


                // draw polygons enabled for selected category
                if (enabledPoly !== undefined && enabledPoly.length > 0) {

                    var polyData = {};
                    for (var i = 0; i < enabledPoly.length; i++) {
                        var ep = enabledPoly[i]
                        var polyId = ep.cid;
                        for (var j = 0; j < poly.length; j++) {
                            var global_poly = poly[j];
                            if (global_poly.cid === polyId) {
                                polyData = global_poly;
                                break;
                            }

                        }

                        var points = polyData.points;
                        if (points !== undefined && points.length > 1) {
                            ctx.strokeStyle="#" + polyData.color;
                            ctx.beginPath()

                            item = points[0];
                            screenPoint = getMappointFromCoord(item.lat, item.lon)
                            ctx.moveTo(screenPoint[0], screenPoint[1])
                            for (var k = 1; k < points.length; k++ ) {
                                item = points[k];
                                screenPoint = getMappointFromCoord(item.lat, item.lon)
                                ctx.lineTo(screenPoint[0], screenPoint[1])
                            }
                            ctx.stroke();

                        }


                    }
                }



            }

            ///////////////
            //            if (gpsModel !== undefined) {
            //              refreshGPSModelCurrentPosition();

            //                ctx.strokeStyle="#ff0000"
            //                ctx.beginPath()
            //                c = 0


            //                for (i = 0; i < gpsModel.count; i++) {
            //                    item = gpsModel.get(i);
            //                    if (item.valid !== "true") {
            //                        continue;
            //                    }

            //                    screenPoint = getMappointFromCoord(item.lat, item.lon)
            //                    if (c++ == 0) {
            //                        ctx.moveTo(screenPoint[0], screenPoint[1])
            //                    } else {
            //                        ctx.lineTo(screenPoint[0], screenPoint[1])
            //                    }
            //                }
            //                ctx.stroke();
            //            }

            ctx.restore();

            console.timeEnd("canvas-onPaint")
        }


    }


    Rectangle {
        id: scaleBar
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.topMargin: 16
        anchors.top: parent.top
        color: "#000000"
        border.width: 1
        border.color: "#ffffff"
        smooth: false
        height: 6
        width: scaleBarLength[0]
    }

    NativeText {
        text: F.formatDistance(scaleBarLength[1], {'distanceUnit':'m'})
        anchors.horizontalCenter: scaleBar.horizontalCenter
        anchors.top: scaleBar.bottom
        anchors.topMargin: 8
        style: Text.Outline
        styleColor: "white"
        font.pixelSize: 24
    }

    function updateGeocaches () {
        //        console.debug("Update polygons called")

        /*
      var from = getCoordFromScreenpoint(0,0)
        var to = getCoordFromScreenpoint(pinchmap.width,pinchmap.height)


        FlightData.sendMessage({
                                   'action': 'visibleMapChanged',
                                   'simple_objects': simple_objects,
                                   'polygon_objects': polygon_objects,
                                   'min_latitude':  Math.min(from[0],to[0]),
                                   'min_longitude': Math.min(from[1],to[1]),
                                   'max_latitude':  Math.max(from[0],to[0]),
                                   'max_longitude': Math.max(from[1],to[1]),
                                   'zoom': zoomLevel,
                                   'flight_data_container': flight_data_container
                                   //                                 'mapPtr': map,
                                   //                                 'tmpCoord': tmpCoord
                               });
*/
        canvas.requestPaint()

    }

    PinchArea {
        id: pincharea;

        property double __oldZoom;
        property double __oldAngle;


        anchors.fill: parent;

        function calcZoomDelta(p) {
            var newZoomLevel = (Math.log(p.scale)/Math.log(2)) + __oldZoom;
            pinchmap.setZoomLevelPoint(newZoomLevel, p.center.x, p.center.y);
            if (rotationEnabled) {
                rot.angle = __oldAngle + p.rotation
            }
            pan(p.previousCenter.x - p.center.x, p.previousCenter.y - p.center.y);
        }

        onPinchStarted: {
            __oldZoom = pinchmap.zoomLevel;
            __oldAngle = rot.angle
        }

        onPinchUpdated: {
            calcZoomDelta(pinch);
        }

        onPinchFinished: {
            calcZoomDelta(pinch);
        }


        MouseArea {
            id: mousearea;
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            property bool __isPanning: false;
            property bool __isDragingPoint: false;
            property int __lastX: -1;
            property int __lastY: -1;
            property int __firstX: -1;
            property int __firstY: -1;
            property int maxClickDistance: 100;

            cursorShape: showRuler ? Qt.CrossCursor : Qt.ArrowCursor


            anchors.fill : parent;

            onWheel:  {
                if (wheel.angleDelta.y > 0) {
                    setZoomLevelPoint(pinchmap.zoomLevel + 1, wheel.x, wheel.y);
                } else {
                    setZoomLevelPoint(pinchmap.zoomLevel - 1, wheel.x, wheel.y);
                }
            }

            onDoubleClicked: {
                if (mouse.button == Qt.RightButton) {
                    return;
                }

                // selection of item from pointsList
                if (filterCupData === 0) { // if tab == points
                    //                    var c = getCoordFromScreenpoint(mouse.x, mouse.y)

                    var minDistance = 20; // px
                    var minIndex = -1;

                    for (var i = 0; i < pointsListModel.count; i++) {
                        var item = pointsListModel.get(i);
                        var screen = getScreenpointFromCoord(item.lat, item.lon)
                        var distance = F.euclidDistance(screen[0], screen[1], mouse.x, mouse.y);
                        //                                F.getDistanceTo(item.lat, item.lon, c[0], c[1]);
                        if (distance < minDistance) {
                            minIndex = i;
                            minDistance = distance;
                        }
                    }
                    if (minIndex !== -1) {
                        var item = pointsListModel.get(minIndex);
                        pointselectedFromMap(item.pid);
                    }
                }

            }



            onPressed: {
                if (mouse.button == Qt.RightButton) {
                    showRuler = !showRuler;
                    return;
                }


                pannedManually()
                __isPanning = __isDragingPoint = false;

                if (showRuler) {
                    ruler.visible = true;
                    var pos = getCoordFromScreenpoint(mouse.x, mouse.y)
                    ruler.startPoint = getMappointFromCoord(pos[0], pos[1])
                    ruler.endPoint = getMappointFromCoord(pos[0], pos[1])

                } else {

                    if (filterCupData === 0) {
                        for (var i = 0; i < pointsListModel.count; i++) {
                            var item = pointsListModel.get(i);
                            if (item.pid === pointsSelectedPid) {
                                var screen = getScreenpointFromCoord(item.lat, item.lon)

                                var distance = F.euclidDistance(screen[0], screen[1], mouse.x, mouse.y);
                                pointsSelectedIndex = i;
                                if (distance < 20) { // 20 px
                                    __isDragingPoint = true;
                                }
                            }
                        }
                    }

                    if (!__isDragingPoint) {
                        __isPanning = true;
                    }

                }

                __lastX = mouse.x;
                __lastY = mouse.y;
                __firstX = mouse.x;
                __firstY = mouse.y;

            }

            onReleased: {
                if (mouse.button == Qt.RightButton) {
                    return;
                }

                ruler.visible = false;

                if (!showRuler) {

                    if ((__isDragingPoint) && (filterCupData === 0)) {

                        var c = getCoordFromScreenpoint(mouse.x, mouse.y)
                        pointsListModel.setProperty(pointsSelectedIndex, "lat", c[0]);
                        pointsListModel.setProperty(pointsSelectedIndex, "lon", c[1]);

                        pointMovedFromMap({
                                              "pid" : pointsSelectedPid,
                                              "lat": c[0],
                                              "lon": c[1]
                                          });
                    }

                    if (__isPanning) {
                        panEnd();
                    }

                    // pri kliknuti do mapy

                    var click_coord = getCoordFromScreenpoint(mouse.x,mouse.y)
                    var minDist = F.earth_radius;
                    var minIndex = 0;
                    var item, i, nextItem;

                    // najde souradnici nejblizsiho bodu v datech gps loggeru
                    if ((gpsModel !== undefined) && (gpsModel.count > 2)) {
                        for (i = 0; i < gpsModel.count; i++) {
                            item = gpsModel.get(i);
                            if (item.valid !== "true") {
                                continue;
                            }
                            var dist = F.getDistanceTo(click_coord[0], click_coord[1], item.lat, item.lon);
                            if (dist < minDist) {
                                minDist = dist;
                                minIndex = i;
                            }

                        }

                        currentPositionIndex = minIndex;
                    }

                }

                __isPanning = false;
                __isDragingPoint = false;


            }

            onPositionChanged: {

                if (mouse.button == Qt.RightButton) {
                    return;
                }


                if (showRuler) {
                    var pos = getCoordFromScreenpoint(mouse.x, mouse.y)
                    ruler.endPoint = getMappointFromCoord(pos[0], pos[1])

                    var posFirst = getCoordFromScreenpoint(__firstX, __firstY);
                    rulerDistance = F.getDistanceTo(pos[0], pos[1], posFirst[0], posFirst[1])
                    ruler.distance = F.getDistanceTo(pos[0], pos[1], posFirst[0], posFirst[1]).toFixed(1) + " m"

                }


                if (__isPanning) {
                    var dx = mouse.x - __lastX;
                    var dy = mouse.y - __lastY;
                    pan(-dx, -dy);
                    __lastX = mouse.x;
                    __lastY = mouse.y;
                    /*
                    once the pan threshold is reached, additional checking is unnecessary
                    for the press duration as nothing sets __wasClick back to true
                    */
                    //                    if (__wasClick && Math.pow(mouse.x - __firstX, 2) + Math.pow(mouse.y - __firstY, 2) > maxClickDistance) {
                    //                        __wasClick = false;
                    //                    }
                }
                if (__isDragingPoint) {
                    var dx = mouse.x - __lastX;
                    var dy = mouse.y - __lastY;

                    if (pointsSelectedIndex >= 0) {
                        var c = getCoordFromScreenpoint(mouse.x, mouse.y)
                        var item = pointsListModel.get(pointsSelectedIndex);
                        pointsListModel.setProperty(pointsSelectedIndex, "lat", c[0]);
                        pointsListModel.setProperty(pointsSelectedIndex, "lon", c[1]);
                    }

                    __lastX = mouse.x;
                    __lastY = mouse.y;

                }
            }

            onCanceled: {
                __isPanning = false;
                __isDragingPoint = false;
            }
        }

    }


    ListModel {
        id: pointsListModel;
    }


    Component.onCompleted: {
        focus = true; // the previous line is not working
    }

    Keys.onPressed: {
        if (gpsModel === undefined) {
            currentPositionIndex = 0;
            return;
        }

        switch (event.key ) {
        case Qt.Key_Left:
            currentPositionIndex = (currentPositionIndex < 1) ? 0 :(currentPositionIndex - 1)
            break;
        case Qt.Key_Right:
            currentPositionIndex = (currentPositionIndex + 1)%gpsModel.count;
            break;
        }

    }

    FileReader {
        id: filereader
    }


}
