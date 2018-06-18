import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import cz.mlich 1.0
import "parseCup.js" as Cup
import "parser_fn.js" as Parser
import "functions.js" as F

ApplicationWindow {
    id: mainWindow
    // title + filename + modified
    //% "Trajectory Editor"
    title: qsTrId("main-window-title") + " " + ((opened_track_filename.length > 0) ? ("- " + F.basename(opened_track_filename)) : "") + (document_changed ? "*" : "")
    width: 800
    height: 600
    property variant tracks

    property string opened_track_filename: "";
    property bool document_changed: false;
    property string tucekSettingsDIR: "results"
    property string tucekSettingsCSV: "tucek-settings.csv"

    onClosing: {
        close.accepted = false;
        app_before_close();
    }

    function app_before_close() {
        if (document_changed) {
            confirmUnsavedDialog.action = function() {
                Qt.quit();
            }

            confirmUnsavedDialog.open();
            return;
        }

        Qt.quit();

    }

    menuBar: MenuBar {
        Menu {
            //% "&File"
            title: qsTrId("main-file-menu")
            MenuItem {
                //% "&New"
                text: qsTrId("main-file-menu-new")
                onTriggered: {
                    if (document_changed) {
                        confirmUnsavedDialog.action = function() {
                            opened_track_filename = "";
                            loadDefaults();
                        }

                        confirmUnsavedDialog.open();
                        return;
                    }
                    opened_track_filename = "";
                    loadDefaults();
                }

            }
            MenuItem {
                //% "&Load"
                text: qsTrId("main-file-menu-load")
                shortcut: StandardKey.Open;
                onTriggered: {
                    if (document_changed) {
                        confirmUnsavedDialog.action = function() {
                            loadFileDialog.open();
                        }

                        confirmUnsavedDialog.open();
                        return;
                    }

                    loadFileDialog.open();
                }
            }
            MenuItem {
                //% "&Save"
                text: qsTrId("main-file-menu-save")
                shortcut: StandardKey.Save;
                onTriggered: {
                    if (opened_track_filename === "") {
                        saveFileDialog.action = function() {};
                        saveFileDialog.open()
                        return;
                    }
                    document_changed = false;

                    file_reader.write(Qt.resolvedUrl(opened_track_filename), JSON.stringify(tracks));
                    storeTrackSettings_with_dir_check(opened_track_filename);

                }

            }

            MenuItem {
                //% "Save &as..."
                text: qsTrId("main-file-menu-save-as")
                shortcut: StandardKey.SaveAs;
                onTriggered: {
                    saveFileDialog.action = function() {};
                    saveFileDialog.open()
                }
            }

            MenuItem {
                //% "Load &GFW"
                text: qsTrId("main-file-menu-load-gfw");
                onTriggered: {
                    gfwDialog.show();
                    loadGfwMenuItem.checked = true;
                }
            }

            MenuItem {
                //% "&Import"
                text: qsTrId("main-file-menu-import")
                onTriggered: {
                    console.log("import kml, gpx, cup")
                    importFileDialog.open()
                }
            }

            MenuItem {
                //% "E&xport"
                text: qsTrId("main-file-menu-export")
                onTriggered: {
//                    exportKml("file:///var/www/html/tucek2/export.kml")
//                    exportGpx("file:///var/www/html/tucek2/export.gpx");
                    exportFileDialog.open()
                }

            }
            MenuItem {
                //% "E&xit"
                text: qsTrId("main-file-menu-exit")
                onTriggered: {
                    app_before_close();
                }
            }


        }
        Menu {
            //% "&Edit"
            title: qsTrId("main-edit-menu")
            MenuItem {
                //% "Clone"
                text: qsTrId("main-menu-edit-clone")
                onTriggered: {
                    cloneDialog.show();
                }
            }
            MenuItem {
                //% "Zoom to points"
                text: qsTrId("main-menu-edit-zoom-to-points")
                onTriggered: {
                    map.pointsInBounds();
                }
                shortcut: "Ctrl+0"
            }
            MenuItem {
                //% "Zoom in"
                text: qsTrId("main-menu-edit-zoom-in")
                shortcut: StandardKey.ZoomIn;
                onTriggered: {
                    map.zoomIn();
                }
            }
            MenuItem {
                //% "Zoom out"
                text: qsTrId("main-menu-edit-zoom-out")
                shortcut: StandardKey.ZoomOut;
                onTriggered: {
                    map.zoomOut();
                }
            }

            MenuItem {
                id: main_menu_edit_show_track_always
                //% "Show track always"
                text: qsTrId("main-menu-edit-show-track-always");
                checkable: true;

            }

            MenuItem {
                id: main_menu_edit_show_ruler
                //% "Ruler"
                text: qsTrId("main-menu-edit-ruler")
                checkable: true;
                checked: map.showRuler;
                onCheckedChanged: {
                  map.showRuler = checked;
                }
            }

            MenuItem {
                id: main_menu_edit_autocenter_point
                //% "Automaticaly snap to center"
                text: qsTrId("main-menu-edit-autocenter")
                checkable: true;
                checked: true;
                onCheckedChanged: {
                    map.autocenter = checked;
                }
            }

        }

        Menu {
            //% "&Map"
            title: qsTrId("main-map-menu")
            ExclusiveGroup {
                id: mapTypeExclusive
            }
            ExclusiveGroup {
                id: mapTypeSecondaryExclusive
            }

            MenuItem {
                //% "&None"
                text: qsTrId("main-map-menu-none")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    map.url = "";
                    map.url_subdomains = [];
                }
                shortcut: "Ctrl+1"

            }
            MenuItem {
                //% "&Local"
                text: qsTrId("main-map-menu-local")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    setLocalPath();
                }
                Component.onCompleted: { // default value
                    checked = true;
                    setLocalPath();

                }
                shortcut: "Ctrl+2"
                function setLocalPath() {
                    var homepath = Qt.resolvedUrl("file://"+QStandardPathsHomeLocation+"/Maps/OSM/")
                    var binpath = Qt.resolvedUrl("file://"+QStandardPathsApplicationFilePath +"/Maps/OSM/");
                    map.url_subdomains = [];
                    if (file_reader.file_exists(binpath)) {
                        console.warn("local map " + binpath)
                        map.url = binpath + "%(zoom)d/%(x)d/%(y)d.png"
                    } else if (file_reader.file_exists(homepath)) {
                        console.warn("local map " + homepath)
                        map.url = homepath + "%(zoom)d/%(x)d/%(y)d.png"
                    } else {
                        console.warn("local map not found")
                        map.url = "";
                    }
                }

            }
            MenuItem {
                //% "&OSM Mapnik"
                text: qsTrId("main-map-menu-osm")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    map.url = "http://%(s)d.tile.openstreetmap.org/%(zoom)d/%(x)d/%(y)d.png";
                    map.url_subdomains = ['a','b', 'c'];
                }
                shortcut: "Ctrl+3"

            }
            MenuItem {
                //% "Google &Roadmap"
                text: qsTrId("main-map-menu-google-roadmap")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    map.url = "http://%(s)d.google.com/vt/lyrs=m@248407269&hl=x-local&x=%(x)d&y=%(y)d&z=%(zoom)d&s=Galileo"
                    map.url_subdomains = ['mt0','mt1','mt2','mt3']
                }
                shortcut: "Ctrl+4"
            }

            MenuItem {
                //% "Google &Terrain"
                text: qsTrId("main-map-menu-google-terrain")
                checkable: true;
                exclusiveGroup: mapTypeExclusive
                onTriggered: {
                    map.url = "http://%(s)d.google.com/vt/lyrs=t,r&x=%(x)d&y=%(y)d&z=%(zoom)d"
                    map.url_subdomains = ['mt0','mt1','mt2','mt3']
                }
                shortcut: "Ctrl+5"
            }

            MenuItem {
                //% "Google &Satellite"
                text: qsTrId("main-map-menu-google-satellite")
                exclusiveGroup: mapTypeExclusive
                checkable: true;
                onTriggered: {
                    map.url = 'http://%(s)d.google.com/vt/lyrs=s&x=%(x)d&y=%(y)d&z=%(zoom)d';
                    map.url_subdomains = ['mt0','mt1','mt2','mt3']
                }
                shortcut: "Ctrl+6"
            }
            MenuItem {
                //% "Custom tile layer"
                text: qsTrId("main-map-menu-custom-tile-layer")
                exclusiveGroup: mapTypeExclusive
                checkable: true;
                onTriggered: {
                    mapurl_dialog.open();
                    map.url_subdomains = [];
                }
                shortcut: "Ctrl+7"
            }

            MenuItem {
                //% "Airspace Off"
                text: qsTrId("main-map-menu-airspace-off")
                exclusiveGroup: mapTypeSecondaryExclusive
                checkable: true;
                checked: true;
                onTriggered: {
                    map.airspaceUrl = ""
                    map.mapAirspaceVisible = false;
                }
            }

            MenuItem {
                //% "Airspace (prosoar.de)"
                text: qsTrId("main-map-menu-airspace-prosoar")
                exclusiveGroup: mapTypeSecondaryExclusive
                checkable: true;
                onTriggered: {
                    map.airspaceUrl= Qt.resolvedUrl("file://"+QStandardPathsApplicationFilePath +"/Maps/airspace/tiles/")+"%(zoom)d/%(x)d/%(y)d.png"
                    map.mapAirspaceVisible = true;
                }
            }

            MenuItem {
                //% "Airspace (local)"
                text: qsTrId("main-map-menu-airspace-local")
                exclusiveGroup: mapTypeSecondaryExclusive
                checkable: true;
                onTriggered: {
                    map.airspaceUrl= Qt.resolvedUrl("file://"+QStandardPathsApplicationFilePath +"/Maps/airspace/tiles/")+"%(zoom)d/%(x)d/%(y)d.png"
                    map.mapAirspaceVisible = true;
                }
            }


            MenuItem {
                id: loadGfwMenuItem
                //% "Show &gfw image"
                text: qsTrId("main-map-menu-gfw")
                checkable:  true;
                onTriggered: {
                    if (checked && gfwDialog.wffiles.count == 0) {
                        gfwDialog.show();

                    }

                    console.log("gfw + gif")
                }

            }


        }

        Menu {
            //% "&Help"
            title: qsTrId("main-help-menu")
            MenuItem {
                //% "&About"
                text: qsTrId("main-help-menu-about")
                onTriggered: {
                    aboutDialog.show();
                }

            }

        }
    }



    SplitView {
        anchors.fill: parent;

        Rectangle {
            clip:true;
            height: parent.height
            width: parent.width/2;

            PinchMap {
                id: map;
                anchors.fill: parent;
                wfVisible: loadGfwMenuItem.checked && (!gfwDialog.visible);
                trackModel: tracks
                filterCupData: cupTextDataTabs.currentIndex;
                filterCupCategory: cupTextDataTabs.selectedCategoryIndex;
                showTrackAnyway: main_menu_edit_show_track_always.checked
                onPointselectedFromMap: {
                    cupTextDataTabs.pointPidSelectedFromMap = pid;
                }

                onPointMovedFromMap: {
                    document_changed = true;
                    cupTextDataTabs.newPointPosition = new_point;
                }
                onConnComputedData: {
                    cupTextDataTabs.computedData = connInfo;
                }
            }


        }

        CupTextData {
            id: cupTextDataTabs;
            tracksData: tracks
            width: parent.width/2;
            height: parent.height
            mapCenterLat: map.latitude
            mapCenterLon: map.longitude
            showTrackAlways: main_menu_edit_show_track_always.checked
            onPointsUpdated: {
                var tmp = {
                    "points" : p,
                    "tracks": tracks.tracks,
                    "poly" : tracks.poly,

                }
                tracks = tmp;
                document_changed = true;
                map.requestUpdate()
            }
            onPolygonsUpdated: {
                var tmp = {
                    "points" : tracks.points,
                    "tracks": tracks.tracks,
                    "poly" : p,

                }
                tracks = tmp;
                document_changed = true;
                map.requestUpdate()

            }

            onTracksUpdated: {
                var tmp = {
                    "points" : tracks.points,
                    "tracks": t,
                    "poly" : tracks.poly,

                }
                tracks = tmp;

//                console.log(JSON.stringify(tracks))
                document_changed = true;
                map.requestUpdate()

            }

            onPointListItemSelected: {
                map.pointsSelectedPid = pid;
            }
            onTrackListItemSelected: {
                map.tracksSelectedTid = tid;
            }
            onPolyListItemSelected: {
                map.polySelectedCid = cid;
            }

            onPointSnap: {
                map.pointSnap = pid;
                map.requestUpdate();
            }

        }

/*
        TracksList {
            tracksData: tracks
            width: 300;
            height: parent.height
        }
*/

    }

    AboutDialog {
        id: aboutDialog;
    }


    GFWDialog {
        id: gfwDialog
        onAccepted: {
            map.worldfiles = list

        }
        onCanceled: {
            loadGfwMenuItem.checked = false;
        }
    }


    FileReader {
        id: file_reader
    }

    ImageSaver {
        id: image_saver
    }

    TextDialog {
        id: mapurl_dialog;

        //% "Custom map tile configuration"
        title: qsTrId("main-map-dialog-title")

        //% "Enter URL";
        question: qsTrId("main-map-dialog-question")

        text: "http://m3.mapserver.mapy.cz/ophoto-m/%(zoom)d-%(x)d-%(y)d"
        onAccepted: {
            map.url = text;
        }

    }

    MessageDialog {
        id: errorDialog;
        //% "Error"
        title: qsTrId("error-dialog")
        icon: StandardIcon.Critical;
        onAccepted: {
            Qt.quit();
        }
    }

    FileDialog {
        id: loadFileDialog;
        nameFilters: [
            "Laa Editor data file (*.json)"
        ]
        onAccepted: {
            document_changed = false;
            opened_track_filename = fileUrl;
            tracks = JSON.parse(file_reader.read(Qt.resolvedUrl(fileUrl)))
            map.requestUpdate()
        }
    }

    FileDialog {
        id: saveFileDialog;
        nameFilters: [
            "Laa Editor data file (*.json)",
            "All files (*)"
        ]

        selectExisting: false;
        property var action; // function called

        onAccepted: {
            document_changed = false;
            if (selectedNameFilterExtensions === "*.json") {
                if (String(fileUrl).match(/\.json$/)) {
                    opened_track_filename = fileUrl;
                } else {
                    // FIXME: the overwrite is checked per fileUrl, but not fileUrl + suffix
                    console.log("warning overwrite is not checked")
                    opened_track_filename = fileUrl + ".json";
                }
            } else {
                opened_track_filename = fileUrl
            }


            file_reader.write(Qt.resolvedUrl(opened_track_filename), JSON.stringify(tracks));
            storeTrackSettings_with_dir_check(Qt.resolvedUrl(tucekSettingsCSV));

            action();
        }
    }

    MessageDialog {
        id: confirmUnsavedDialog;
        //% "Are you sure?"
        title: qsTrId("confirm-unsaved-title")
        //% "Your changes have not been saved."
        text: qsTrId("confirm-usaved-text")

        property var action; // function called on discard and after save (i.e. exit or new)

        standardButtons: StandardButton.Save | StandardButton.Discard | StandardButton.Cancel;
        onAccepted: {

            if (opened_track_filename === "") {
                saveFileDialog.action = action;
                saveFileDialog.open()
                return;
            }
            file_reader.write(Qt.resolvedUrl(opened_track_filename), JSON.stringify(tracks));
            storeTrackSettings_with_dir_check(Qt.resolvedUrl(tucekSettingsCSV));

            action();
        }

        onDiscard: {
            action();
        }
    }



    FileDialog {
        id: importFileDialog
        nameFilters: [
            "Any supported format (*.cup *.gpx *.kml *.igc)",
            "SeeYou Waypoint file (*.cup)",
            "GPS exchange Format (*.gpx)",
            "Keyhole Markup Language (*.kml)",
            "IGC (*.igc)",
            "All files (*)",
        ]

        onAccepted: {
            var str = String(fileUrl);
            if (str.match(/\.cup$/i)) {
                importCup(fileUrl);
            } else if (str.match(/\.kml$/i)) {
                importKml(fileUrl)
            } else if (str.match(/\.gpx$/i)) {
                importGpx(fileUrl)
            } else if (str.match(/\.igc$/i)) {
                importIgc(fileUrl)
            } else {
                console.error("unsupported file format (please rename file): " + fileUrl)
            }
        }

    }

    FileDialog {
        id: exportFileDialog;
        selectExisting: false;

        nameFilters: [
            "Keyhole Markup Language (*.kml)",
            "GPS exchange Format (*.gpx)",
            "See You cup (*.cup)",
        ]
        onAccepted: {
            var str = String(fileUrl);
            if (str.match(/\.kml$/)) {
                exportKml(fileUrl);
            } else if (str.match(/\.gpx$/)) {
                exportGpx(fileUrl);
            } else if (str.match(/\.cup$/)) {
                exportCup(fileUrl);
            } else {
                console.error("unsupported file format (please add file extension)")
            }
        }
    }

    CloneDialog {
        id: cloneDialog;
        cupData: tracks
        onTracksUpdated: {
            var tmp = {
                "points" : tracks.points,
                "tracks": t,
                "poly" : tracks.poly,

            }
            tracks = tmp;
            document_changed = true;

            map.requestUpdate()

        }

    }

    Component.onCompleted: {
        loadDefaults()

//        var default_data_file = "file:///var/www/html/tucek2/2014-KOTV.json";
//        var default_data = file_reader.read(Qt.resolvedUrl(default_data_file))
//        tracks = JSON.parse(default_data);

//        var cupFilename = "file:///home/jmlich/Desktop/x.cup"
//        exportCup(cupFilename);

//        var kmlFilename = "file:///home/jmlich/workspace/tucek/data/kml/2013_skutec_final.kml"
//        importKml(kmlFilename);
//        var gpxFilename = "file:///home/imlich/workspace/tucek/docs/2013/soutěže/skutec pro import.gpx"
//        var gpxFilename = "file:///var/www/html/tucek2/x.gpx"
//        importGpx(gpxFilename);

        map.requestUpdate()

    }

    function loadDefaults() {
        document_changed = false;
        var defaults_files = [
                    "file:///" + QStandardPathsApplicationFilePath + "/editor_defaults.json",
                    "file:///" + QStandardPathsApplicationFilePath + "/../share/editor/editor_defaults.json"
                ];

        var selected_default;
        defaults_files.forEach(function(defaults_file) {
            if (file_reader.file_exists(Qt.resolvedUrl(defaults_file))) {
                selected_default = Qt.resolvedUrl(defaults_file)
            }
        })

        if (selected_default === undefined) {
            console.log("Error: cannot load defaults");
            //% "Cannot load defaults"
            errorDialog.text = qsTrId("error-defaults-file") + "\neditor_defaults.json";
            errorDialog.open();
            return;
        }
        tracks = JSON.parse(file_reader.read(Qt.resolvedUrl(selected_default)))

        map.requestUpdate()

    }

    function importCup(filename) {
        if (!file_reader.file_exists(Qt.resolvedUrl(filename))) {
            console.log("file not exists "+ filename);
            return;
        }

        var cupData = Cup.parse(file_reader.read(Qt.resolvedUrl(filename)));

        var wpts = cupData.waypoints;

        var newArr = tracks.points;
        var maxPid = 0;
        var i = 0;
        for (i = 0; i < newArr.length; i++) {
            var item = newArr[i];
            maxPid = Math.max(item.pid, maxPid);
        }

        for (i = 0; i < wpts.length; i++) {
            var wpt = wpts[i];
            newArr.push({
                            "pid": maxPid+ 1 +i,
                            "name": wpt.Name,
                            "lat": wpt.Latitude,
                            "lon": wpt.Longitude,
                        })
        }

        var tmp = {
            "points" : newArr,
            "tracks": tracks.tracks,
            "poly" : tracks.poly,

        }
        tracks = tmp;
        map.requestUpdate()

    }

    function importKml(filename) {
        if (!file_reader.file_exists(Qt.resolvedUrl(filename))) {
            console.log("file not exists "+ filename);
            return;
        }

        var json = kmlConv.kmlToJSONString(Qt.resolvedUrl(filename))
        var kml = JSON.parse(json);

        var kmlpts = kml.points;


        var newPoints = tracks.points;
        var maxPid = 0;
        var i = 0;
        var item;
        for (i = 0; i < newPoints.length; i++) {
            item = newPoints[i];
            maxPid = Math.max(item.pid, maxPid);
        }


        for (i = 0; i < kmlpts.length; i++) {
            item = kmlpts[i];
            newPoints.push({
                            "pid": maxPid+ 1 +i,
                            "name": item.name,
                            "lat": item.lat,
                            "lon": item.lon,
                        })
        }

        var newPoly = tracks.poly;
        var maxCid = 0;
        for (i = 0; i < newPoly.length; i++) {
            item = newPoly[i];
            maxCid = Math.max(item.cid, maxCid);
        }

        var kmlpoly = kml.poly;
        for (i = 0; i < kmlpoly.length; i++) {
            var kmlPolyItem = kmlpoly[i];
            var newPolyItem = {"cid": maxCid+1+i,
                        "name": kmlPolyItem.name,
                        "color": kmlPolyItem.color,
                        "points" : kmlPolyItem.points,
                        "closed": false,
                    }
            newPoly.push(newPolyItem)

        }

        var tmp = {
            "points" : newPoints,
            "poly" : newPoly,
            "tracks": tracks.tracks,
        }
        tracks = tmp;
        map.requestUpdate()

    }

    function importGpx(filename) {
        if (!file_reader.file_exists(Qt.resolvedUrl(filename))) {
            console.log("file not exists "+ filename);
            return;
        }

        var json = gpxConv.gpxToJSONString(Qt.resolvedUrl(filename))
        var gpx= JSON.parse(json);


        var kmlpts = gpx.points;

        var newPoints = tracks.points;
        var maxPid = 0;
        var i = 0;
        var item;
        for (i = 0; i < newPoints.length; i++) {
            item = newPoints[i];
            maxPid = Math.max(item.pid, maxPid);
        }


        for (i = 0; i < kmlpts.length; i++) {
            item = kmlpts[i];
            newPoints.push({
                            "pid": maxPid+ 1 +i,
                            "name": item.name,
                            "lat": item.lat,
                            "lon": item.lon,
                        })
        }

        var newPoly = tracks.poly;
        var maxCid = 0;
        for (i = 0; i < newPoly.length; i++) {
            item = newPoly[i];
            maxCid = Math.max(item.cid, maxCid);
        }

        var kmlpoly = gpx.poly;
        for (i = 0; i < kmlpoly.length; i++) {
            var kmlPolyItem = kmlpoly[i];
            var newPolyItem = {"cid": maxCid+1+i,
                        "name": kmlPolyItem.name,
                        "color": kmlPolyItem.color,
                        "points" : kmlPolyItem.points,
                        "closed": false,
                    }
            newPoly.push(newPolyItem)

        }

        var tmp = {
            "points" : newPoints,
            "poly" : newPoly,
            "tracks": tracks.tracks,
        }
        tracks = tmp;
        map.requestUpdate()



    }


    function exportKml(filename) {
        var str;
        str="<?xml version=\"1.0\" encoding=\"UTF-8\"?> <!-- Generator: LAA Editor--> <kml xmlns='http://earth.google.com/kml/2.1'><Document><Folder><name>"+F.basename(filename)+"</name><open>1</open>";


        var points = tracks.points;
        var item;

        if (points.length > 0) {
            item = points[0]
            str += "<LookAt><longitude>"+item.lon+"</longitude> <latitude>"+item.lat+"</latitude> <altitude>0</altitude><range>3000,000000000000000000</range> <tilt>45</tilt> <heading>0</heading> </LookAt>"
        }
        for (var i = 0; i < points.length; i++) {
            item = points[i];
            str += "<Placemark>
  <name>"+item.name+"</name>
  <Point>
    <extrude>0</extrude>
    <altitudeMode>clampToGround</altitudeMode>
    <coordinates>"+item.lon+","+item.lat+"</coordinates>
  </Point>
</Placemark>"


        }

        var poly = tracks.poly;
        for (var i = 0; i< poly.length; i++) {
            item = poly[i];
            var coordStr = "";
            var color = item.color;
            if (color.length === 6) {
                color = "FF" + color;
            }

            var polyPoints = item.points;
            for (var j = 0; j < polyPoints.length; j++) {
                var polyPoint = polyPoints[j];
                coordStr += polyPoint.lon + "," + polyPoint.lat + "
"
            }

            str += "<Placemark>
  <name>"+item.name+"</name>
  <Style>
    <LineStyle>
      <color>"+color+"</color>
      <width> 4 </width>
    </LineStyle>
  </Style>
  <LinearRing>
    <extrude>0</extrude>
    <tessellate>0</tessellate>
    <coordinates>"+coordStr+"</coordinates>
  </LinearRing>
</Placemark>
"

        }

        var poly = map.polygonCache;
        for (var i = 0; i< poly.length; i++) {
            item = poly[i];
            var coordStr = "";
            var color = item.color;
            if (color.length === 6) {
                color = "FF" + color;
            }

            var polyPoints = item.points;
            for (var j = 0; j < polyPoints.length; j++) {
                var polyPoint = polyPoints[j];
                coordStr += polyPoint.lon + "," + polyPoint.lat + "
"
            }

            str += "<Placemark>
  <name>"+item.name+"</name>
  <Style>
    <LineStyle>
      <color>"+color+"</color>
      <width> 4 </width>
    </LineStyle>
  </Style>
  <LinearRing>
    <extrude>0</extrude>
    <tessellate>0</tessellate>
    <coordinates>"+coordStr+"</coordinates>
  </LinearRing>
</Placemark>
"

        }


        str += "</Folder></Document></kml>";


        file_reader.write(Qt.resolvedUrl(filename), str);



    }

    function exportGpx(filename) {
        var str ="";
        str += "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<gpx
  version=\"1.0\"
  creator=\"LAA Editor - http://www.laa.cz\"
  xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
  xmlns=\"http://www.topografix.com/GPX/1/0\"
  xsi:schemaLocation=\"http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd\">
"
        var points = tracks.points;

        for (var i = 0; i < points.length; i++) {
            var item = points[i];
            str += "<wpt lat=\""+item.lat+"\" lon=\""+item.lon+"\">
  <ele>0.000000</ele>
  <name>"+item.name+"</name>
  <cmt>"+item.name+"</cmt>
  <desc>"+item.name+"</desc>
</wpt>
"
        }


        var poly = tracks.poly;
        for (var i = 0; i< poly.length; i++) {
            var item = poly[i];

            str += "<trk><name>"+item.name+"</name><trkseg>"


            var polyPoints = item.points;
            for (var j = 0; j < polyPoints.length; j++) {
                var polyPoint = polyPoints[j];
                str +="<trkpt lat=\"" + polyPoint.lat + "\" lon=\""+polyPoint.lon+"\">
  <ele>0</ele>
  <time>1970-01-01T00:00:01Z</time>
</trkpt>"
            }
            str += "</trkseg></trk>"
        }

        var poly = map.polygonCache;
        for (var i = 0; i< poly.length; i++) {
            var item = poly[i];
            str += "<trk><name>"+item.name+"</name><trkseg>"

            var polyPoints = item.points;
            for (var j = 0; j < polyPoints.length; j++) {
                var polyPoint = polyPoints[j];
                str +="<trkpt lat=\"" + polyPoint.lat + "\" lon=\""+polyPoint.lon+"\">
  <ele>0</ele>
  <time>1970-01-01T00:00:01Z</time>
</trkpt>"
            }
            str += "</trkseg></trk>"

        }

        str += "</gpx>"

        file_reader.write(Qt.resolvedUrl(filename), str);

    }


    function exportCup(filename) {
        var str ="";
        var i = 0;
        str += "name,code,country,lat,lon,elev,style,rwdir,rwlen,freq,desc\r\n"

        var points = tracks.points;

        for (i = 0; i < points.length; i++) {
            var item = points[i];

            str += "\"" + F.addSlashes(item.name) + "\",PT" + item.pid + ",," + F.getLat(item.lat,{coordinateFormat: "DM"}) + "," + F.getLon(item.lon,{coordinateFormat: "DM"}) + ",-100000000.0m,1,,,,\""+item.name+"\"\r\n";
        }

        str += "-----Related Tasks-----\r\n"

        for (var tidx = 0; tidx < tracks.tracks.length; tidx++) {
            var trk = tracks.tracks[tidx];
            var conn = trk.conn
            var point;

            if (conn.length > 0) {

                str += "\""+F.addSlashes(trk.name)+"\"";
                point = getPtByPid(conn[0].pid , points);
                str += ",\"" + F.addSlashes(point.name) + "\""

                for (i = 0; i < conn.length; i++) {
                    point = getPtByPid(conn[i].pid , points)
                    str += ",\"" + F.addSlashes(point.name) + "\""
                }
                point = getPtByPid(conn[conn.length-1].pid , points);
                str += ",\"" + F.addSlashes(point.name) + "\""
                str += "\r\n";

                for (i = 0; i < conn.length; i++) {
                    var c = conn[i]
                    str += "ObsZone="+(i+1)+",Style=2,R1=" + ((c.radius < 0) ? trk.default_radius : c.radius) +"m,A1=180,Line=1\r\n"
                }
            }
        }

        file_reader.write(Qt.resolvedUrl(filename), str);

    }


    function importIgc(filename) {
        igcFile.load(filename);

        var newArr = tracks.poly;
        var maxCid = 0;
        for (var i = 0; i < newArr.length; i++) {
            var item = newArr[i];
            maxCid = Math.max(item.cid, maxCid);
        }

        var newPoints = [];
        var count = igcFile.count;
        for (var i = 0; i < count; i++) {
            var item = igcFile.get(i)
            if (item.valid === "true") {
                newPoints.push({"lat": item.lat, "lon": item.lon})
            }
        }

        var newPoly = {
            "cid": maxCid+1,
            "name": F.basename(filename),
            "color": "0000FF",
            "points" : newPoints
        }

        newArr.push(newPoly)


        var tmp = {
            "points" : tracks.points,
            "tracks": tracks.tracks,
            "poly" : newArr,

        }
        tracks = tmp;
        map.requestUpdate()


    }

    IgcFile {
        id: igcFile;
    }

    KmlJsonConvertor {
        id: kmlConv
    }
    GpxJsonConvertor {
        id: gpxConv
    }


    function getPtByPid(pid, points) {
        for (var i = 0; i < points.length; i++) {
            var item = points[i]
            if (item.pid == pid) {
                return item;
            }
        }
    }


    function storeTrackSettings_with_dir_check(opened_track_filename) {
        var tucekDir = file_reader.dirname_local(opened_track_filename) + "/" + tucekSettingsDIR;
        var tucekFile = tucekDir + "/" + tucekSettingsCSV;
        if (file_reader.is_dir_and_exists_local(tucekDir)) {
            console.log("writing "+ tucekFile);
            storeTrackSettings(Qt.resolvedUrl(tucekFile));
        } else {
            console.log("Directory "+ tucekDir+" not exists")
        }
    }

    function storeTrackSettings(filename) {
        var str = "";
        var trks = tracks.tracks
        var points = tracks.points;
        var polys = tracks.poly;
        for (var i = 0; i < trks.length; i++) {
            var trk = trks[i]
            var category_name = F.addSlashes(trk.name)
            str += "\"" + category_name + "\";";
            str += "\"" + trk.alt_penalty + "\";";
            str += "\"" + trk.gyre_penalty + "\";";
            str += "\"" + trk.marker_max_score + "\";";
            str += "\"" + trk.oposite_direction_penalty + "\";";
            str += "\"" + trk.out_of_sector_penalty + "\";";
            str += "\"" + trk.photos_max_score + "\";";
            str += "\"" + trk.speed_penalty + "\";";
            str += "\"" + trk.tg_max_score + "\";";
            str += "\"" + trk.tg_penalty + "\";";
            str += "\"" + trk.tg_tolerance + "\";";
            str += "\"" + trk.time_window_penalty + "\";";
            str += "\"" + trk.time_window_size + "\";";
            str += "\"" + trk.tp_max_score + "\";";
            str += "\"" + trk.speed_tolerance + "\";";
            str += "\"" + trk.sg_max_score + "\";";
            str += "\"" + ((trk.preparation_time !== undefined) ? trk.preparation_time : 0) + "\";";

            //            str += "\n";
            //            str += "\"" + category_name + "___PART2" +"\";";

            var conns = trk.conn;


            for (var j = 0; (j < conns.length); j++) {
                var c = conns[j];

                var pt = getPtByPid(c.pid, points)

                //                console.log(JSON.stringify(pt))
                str += "\"" + ((c.flags < 0) ? trk.default_flags : c.flags ) + "\";";
                str += "\"" + ((c.angle < 0) ? c.computed_angle : c.angle) + "\";";
                str += "\"" + ((c.distance < 0) ? c.computed_distance : c.distance) + "\";";
                str += "\"" + ((c.addTime < 0) ? trk.default_addTime : c.addTime) + "\";";
                str += "\"" + ((c.radius < 0) ? trk.default_radius : c.radius) + "\";";
                str += "\"" + ((c.alt_max < 0) ? trk.default_alt_max : c.alt_max) + "\";";
                str += "\"" + ((c.alt_min < 0) ? trk.default_alt_min : c.alt_min) + "\";";
                str += "\"" + ((c.speed_max < 0) ? trk.default_speed_max : c.speed_max) + "\";";
                str += "\"" + ((c.speed_min < 0) ? trk.default_speed_min : c.speed_min) + "\";";
                str += "\"" + F.addSlashes(pt.name) + "\";";
            }



            var section_speed_start_pid = -1;
            var section_alt_start_pid = -1;
            var section_space_start_pid = -1;
            var sections = [];

            for (var j = 0; j < conns.length; j++) {
                var c = conns[j];

                var flags = ((c.flags < 0) ? trk.default_flags : c.flags );
                var section_speed_start = F.getFlagsByIndex(7, flags)
                var section_speed_end   = F.getFlagsByIndex(8, flags)
                var section_alt_start   = F.getFlagsByIndex(9, flags)
                var section_alt_end     = F.getFlagsByIndex(10, flags)
                var section_space_start = F.getFlagsByIndex(11, flags)
                var section_space_end   = F.getFlagsByIndex(12, flags)

                if (section_speed_end && (section_speed_start_pid >= 0)) {
                    var item = {
                        "start": section_speed_start_pid,
                        "end": c.pid,
                        "type":
                        //% "speed"
                        qsTrId("section-type-speed")
                    }
                    sections.push(item);
                    section_speed_start_pid = -1;
                }

                if (section_alt_end && (section_alt_start_pid >= 0)) {
                    var item = {
                        "start": section_alt_start_pid,
                        "end": c.pid,
                        "type":
                        //% "altitude"
                        qsTrId("section-type-altitude")
                    }
                    sections.push(item);
                    section_alt_start_pid = -1;
                }

                if (section_space_end && (section_space_start_pid >= 0)) {
                    var item = {
                        "start": section_space_start_pid,
                        "end": c.pid,
                        "type":
                        //% "space"
                        qsTrId("section-type-space")
                    }
                    sections.push(item);
                    section_space_start_pid = -1;
                }

                if (section_speed_start) {
                    section_speed_start_pid = c.pid;
                }
                if (section_alt_start) {
                    section_alt_start_pid = c.pid;
                }
                if (section_space_start) {
                    section_space_start_pid = c.pid;
                }


            }

            str += "\n";
            str += "\"" + category_name + "___sections" +"\";";


            for (var j = 0; j < sections.length; j++) {
                var section = sections[j];
                var pt_start = getPtByPid(section.start, points)
                var pt_end = getPtByPid(section.end, points)

                str += "\"" + section.type + "\";\"" + section.start + "\";\"" + F.addSlashes(pt_start.name) + "\";\"" + section.end + "\";\"" + F.addSlashes(pt_end.name) + "\";"
            }


            var poly = trk.poly;

            str += "\n";
            str += "\"" + category_name + "___polygons" +"\";";
            for (var j = 0; j < poly.length; j++) {
                var poly_info = poly[j];
                var poly_data = F.getPolyByCid(poly_info.cid, polys);
                str += "\"" +  poly_data.name +"\";"
                str += "\"" + poly_info.score +"\";"
            }


            str += "\n";

        }
        str += ""

        file_reader.write(Qt.resolvedUrl(filename), str);

    }





}
