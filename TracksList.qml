import QtQuick 2.9
import QtQuick.Controls 1.4
import "functions.js" as F
import "geom.js" as G


Rectangle {
    id: trackList

    color: "#dddddd"
    property variant cupData;

    property variant computedData;
    signal pointSelected(int tid);

    onComputedDataChanged: {
        updateComputedValues()
    }

    function updateComputedValues() {
        if (computedData === undefined) {
            return;
        }

        var catIndex = categoryChooser.currentIndex
        var allTracks = cupData.tracks
        var track = allTracks[catIndex];
        if (track === undefined) {
            return;
        }
        var new_conn = track.conn;
        var changed = false;

        for (var i = 0; i< computedData.length; i++) {
            var item = computedData[i];
            if ((item.angle !== undefined)
                    && (new_conn[item.idx] !== undefined)
                    && (item.angle !== new_conn[item.idx].computed_angle)) {
                new_conn[item.idx].computed_angle = item.angle;
                changed = true;
            }
            if ((item.distance !== undefined)
                    && (new_conn[item.idx] !== undefined)
                    && (item.distance !== new_conn[item.idx].computed_distance)) {
                new_conn[item.idx].computed_distance = item.distance;
                changed = true;
            }
        }

        if (!changed) { // update only if changed
            return;
        }


        var new_tracks_arr = [];
        for (var i = 0; i < allTracks.length; i++) {
            var t = allTracks[i];
            if (catIndex === i) {
                var new_arr = getPropertiesFromTrackToDialog()
                new_arr.conn = new_conn;
                new_arr.poly = t.poly
                new_tracks_arr.push(new_arr)
            } else {
                // FIXME
                // bug: pokud se pohne bodem, tak se neprepocitaji uhly a vzdalenosti pro vsechny kategorie
                // workaround: pred ulozenim je potreba proklikat si vsechny kategorie
                new_tracks_arr.push(t);
            }

        }

        newTracks(new_tracks_arr)
        trackToTable(catIndex)

    }

    signal newTracks(variant t);
    signal categoryChanged(int index);

    onCupDataChanged: {
        if (cupData === undefined) {
            return;
        }
        categories.clear();

        var tracks = cupData.tracks;
        for (var i = 0; i < tracks.length; i++) {
            var t = tracks[i];
            categories.append({
                                  "text" : t.name
                              })
        }

        pointsModel.clear();

        var points = cupData.points;
        for (var i = 0; i < points.length; i++) {
            var p = points[i];
            pointsModel.append({
                                   "pid" : p.pid,
                                   "text": p.name + " ("+ p.pid+")",
                                   "name": p.name,
                                   "lat": p.lat,
                                   "lon": p.lon,
                               })
        }

        allPolygonsModel.clear();
        var polygons = cupData.poly;
        for (var i = 0; i < polygons.length; i++) {
            var p = polygons[i];
            allPolygonsModel.append({
                                        "name" : p.name,
                                        "cid": p.cid,
                                        "score": (p.score !== undefined) ? p.score : 0
                                    })
        }

        trackToTable(categoryChooser.currentIndex)


    }


    function trackToTable(index) {

        if (index < 0) {
            return;
        }

        if (cupData === undefined) {
            return;
        }
        tracksModel.clear();

        var track = cupData.tracks[index];
        setPropertiesFromTrackToDialog(track);
        var conns = track.conn;
        for (var i = 0; i < conns.length; i++) {
            var c = conns[i];
            tracksModel.append({
                                   "tid": c.tid,
                                   "pid": c.pid,
                                   "type": c.type,
                                   "flags": c.flags,
                                   "distance": c.distance,
                                   "addTime": c.addTime,
                                   "angle": c.angle,
                                   "computed_angle": c.computed_angle,
                                   "computed_distance": c.computed_distance,
                                   "radius": c.radius,
                                   "speed_min": c.speed_min,
                                   "speed_max": c.speed_max,
                                   "alt_min": c.alt_min,
                                   "alt_max": c.alt_max,
                                   "ptr": c.ptr,
                               })

        }

        selectedPolygonsModel.clear();
        var polygons = track.poly;
        for (var i = 0; i < polygons.length; i++) {
            var p = polygons[i];
            selectedPolygonsModel.append({
                                             "did" : p.did,
                                             "cid": p.cid,
                                             "score": p.score,
                                         })
        }
    }


    function setPropertiesFromTrackToDialog(track) {
        propsDetail.category_name = track.name;
        propsDetail.tg_max_score = track.tg_max_score
        propsDetail.tg_tolerance = track.tg_tolerance;
        propsDetail.tg_penalty = parseFloat(track.tg_penalty);
        propsDetail.sg_max_score = track.sg_max_score;
        propsDetail.tp_max_score = track.tp_max_score;
        propsDetail.marker_max_score = track.marker_max_score;
        propsDetail.photos_max_score = track.photos_max_score;
        propsDetail.time_window_size = track.time_window_size;
        propsDetail.time_window_penalty = track.time_window_penalty;
        propsDetail.alt_penalty = track.alt_penalty;
        propsDetail.gyre_penalty = track.gyre_penalty; // penalizace za krouzeni v %
        propsDetail.oposite_direction_penalty = track.oposite_direction_penalty; // penalizace za protismerny let
        propsDetail.out_of_sector_penalty = track.out_of_sector_penalty; // body
        propsDetail.speed_max_score = (track.speed_max_score !== undefined) ? track.speed_max_score : 200 ;
        propsDetail.speed_penalty = track.speed_penalty; // nedodrzeni rychlosti, body za km
        propsDetail.speed_tolerance = track.speed_tolerance
        propsDetail.preparation_time = (track.preparation_time !== undefined) ? track.preparation_time : 0;
        propsDetail.default_radius = track.default_radius;
        propsDetail.default_alt_min = track.default_alt_min;
        propsDetail.default_alt_max = track.default_alt_max;
        propsDetail.default_speed_min = track.default_speed_min;
        propsDetail.default_speed_max = track.default_speed_max;
        propsDetail.default_flags = parseInt(track.default_flags, 10);

    }

    function getPropertiesFromTrackToDialog() {
        var new_arr = {
            "name": propsDetail.category_name,
            "tg_max_score": propsDetail.tg_max_score,
            "tg_tolerance": propsDetail.tg_tolerance,
            "tg_penalty": propsDetail.tg_penalty,
            "sg_max_score": propsDetail.sg_max_score,
            "tp_max_score": propsDetail.tp_max_score,
            "marker_max_score": propsDetail.marker_max_score,
            "photos_max_score": propsDetail.photos_max_score,
            "time_window_size": propsDetail.time_window_size,
            "time_window_penalty": propsDetail.time_window_penalty,
            "alt_penalty": propsDetail.alt_penalty,
            "gyre_penalty": propsDetail.gyre_penalty,
            "oposite_direction_penalty": propsDetail.oposite_direction_penalty,
            "out_of_sector_penalty": propsDetail.out_of_sector_penalty,
            "speed_max_score": propsDetail.speed_max_score,
            "speed_penalty": propsDetail.speed_penalty,
            "speed_tolerance": propsDetail.speed_tolerance,
            "preparation_time": propsDetail.preparation_time,
            "default_radius": propsDetail.default_radius,
            "default_alt_min": propsDetail.default_alt_min,
            "default_alt_max": propsDetail.default_alt_max,
            "default_speed_min": propsDetail.default_speed_min,
            "default_speed_max": propsDetail.default_speed_max,
            "default_flags": propsDetail.default_flags,
        }


        return new_arr;
    }

    function trackPropertiesChanged() {

        var allTracks = cupData.tracks

        var new_tracks_arr = [];
        for (var i = 0; i < allTracks.length; i++) {
            var t = allTracks[i];

            if (categoryChooser.currentIndex === i) {
                var new_arr = getPropertiesFromTrackToDialog()
                new_arr.conn = t.conn
                new_arr.poly = t.poly
                new_tracks_arr.push(new_arr)
            } else {
                new_tracks_arr.push(t);
            }

        }

        newTracks(new_tracks_arr)

    }


    ListModel {
        id: pointsModel;
    }

    ListModel {
        id: categories
    }

    ListModel {
        id: tracksModel;

        onDataChanged: {
            tracksChanged();
        }

        function tracksChanged() {
            var arr = [];
            for (var i = 0; i < tracksModel.count; i++) {
                var item = tracksModel.get(i);
                arr.push({
                             "tid": item.tid,
                             "pid": item.pid,
                             "type": item.type,
                             "flags": item.flags,
                             "distance": item.distance,
                             "addTime": item.addTime,
                             "angle": item.angle,
                             "radius": item.radius,
                             "computed_angle": item.computed_angle,
                             "computed_distance": item.computed_distance,
                             "speed_min": item.speed_min,
                             "speed_max": item.speed_max,
                             "alt_min": item.alt_min,
                             "alt_max": item.alt_max,
                             "ptr": item.ptr,
                         })
            }


            var allTracks = cupData.tracks

            var new_tracks_arr = [];
            for (var i = 0; i < allTracks.length; i++) {
                var t = allTracks[i];

                if (categoryChooser.currentIndex === i) {
                    var new_arr = t;
                    new_arr.conn = arr
                    new_tracks_arr.push(new_arr)
                } else {
                    new_tracks_arr.push(t);
                }

            }

            newTracks(new_tracks_arr)

        }
    }


    ListModel {
        id: selectedPolygonsModel;

        onDataChanged: {
            selectedPolygonsChanged();
        }

        function selectedPolygonsChanged() {

            var arr = []
            for (var i = 0; i < selectedPolygonsModel.count; i++) {
                var item = selectedPolygonsModel.get(i);
                arr.push({
                             "did": item.did,
                             "cid": item.cid,
                             "score": item.score,
                         })
            }

            var allTracks = cupData.tracks

            var new_tracks_arr = [];
            for (var i = 0; i < allTracks.length; i++) {
                var t = allTracks[i];

                if (categoryChooser.currentIndex === i) {
                    var new_arr = getPropertiesFromTrackToDialog()
                    new_arr.conn = t.conn;
                    new_arr.poly = arr;
                    new_tracks_arr.push(new_arr)
                } else {
                    new_tracks_arr.push(t);
                }

            }

            newTracks(new_tracks_arr)


        }

    }

    ListModel {
        id: allPolygonsModel;
    }

    ListModel {
        id: connectionTypeModel
    }


    Component.onCompleted: {
        //% "None"
        connectionTypeModel.append({text: qsTrId("tracks-list-line-type-none"), typeId: "none"})
        //% "Line"
        connectionTypeModel.append({text: qsTrId("tracks-list-line-type-line"), typeId: "line"})
        //% "Polyline"
        connectionTypeModel.append({text: qsTrId("tracks-list-line-type-polyline"), typeId: "polyline"})
        //% "Mid-point Arc A"
        connectionTypeModel.append({text: qsTrId("tracks-list-line-type-arc1"), typeId: "arc1"})
        //% "Mid-point Arc B"
        connectionTypeModel.append({text: qsTrId("tracks-list-line-type-arc2"), typeId: "arc2"})
//        //% "Edge-point Arc A"
//        connectionTypeModel.append({text: qsTrId("tracks-list-line-type-arc3"), typeId: "arc3"})
//        //% "Edge-point Arc B"
//        connectionTypeModel.append({text: qsTrId("tracks-list-line-type-arc4"), typeId: "arc4"})

    }




    ComboBox {
        id: categoryChooser
        anchors.top: parent.top;
        anchors.left: parent.left
        width: parent.width/3
        anchors.margins: 2

        model: categories;

        onCurrentIndexChanged: {
            trackToTable(currentIndex)
            categoryChanged(currentIndex)
            updateComputedValues();

        }
    }

    Button {
        id: preferences
        //% "Preferences"
        text: qsTrId("track-list-preferences")
        anchors.top: parent.top;
        anchors.left: categoryChooser.right
        width: categoryChooser.width
        anchors.margins: 2

        onClicked: propsDetail.show();

        PropertiesDetail {
            id: propsDetail;

            onAccepted: {
                trackPropertiesChanged();
            }

            onCanceled: {
                var track = cupData.tracks[categoryChooser.currentIndex];
                setPropertiesFromTrackToDialog(track);
            }
        }
    }

    Button {
        anchors.top: parent.top;
        anchors.left: preferences.right
        anchors.right: parent.right
        anchors.margins: 2
        //% "Statistics"
        text: qsTrId("track-list-statistics")

        onClicked: {
            tracksStats.tp_max_score = propsDetail.tp_max_score;
            tracksStats.tg_max_score = propsDetail.tg_max_score;
            tracksStats.sg_max_score = propsDetail.sg_max_score;
            tracksStats.photos_score = propsDetail.photos_max_score;
            tracksStats.markers_score = propsDetail.marker_max_score;
            tracksStats.other_score = "250"

            var tg_count = 0;
            var tp_count = 0;
            var sg_count = 0;
            for (var i = 0; i < tracksModel.count; i++) {
                var item = tracksModel.get(i);
                var flags = (item.flags < 0) ? propsDetail.default_flags : item.flags;
                var tp_enabled = F.getFlagsByIndex(0, flags)
                var tg_enabled = F.getFlagsByIndex(1, flags)
                var sg_enabled = F.getFlagsByIndex(2, flags)
                if (tp_enabled) {
                    tp_count++;
                }
                if (tg_enabled) {
                    tg_count++;
                }
                if (sg_enabled) {
                    sg_count++;
                }
            }

            tracksStats.tg_count = tg_count;
            tracksStats.tp_count = tp_count;
            tracksStats.sg_count = sg_count;

            tracksStats.show();
        }

        TrackStatistics {
            id: tracksStats

            onAccepted: {
                propsDetail.tp_max_score = tracksStats.tp_max_score;
                propsDetail.tg_max_score = tracksStats.tg_max_score;
                propsDetail.sg_max_score = tracksStats.sg_max_score;
                propsDetail.photos_max_score = tracksStats.photos_score;
                propsDetail.marker_max_score = tracksStats.markers_score;
                trackPropertiesChanged();

            }
        }
    }


    SplitView {
        orientation: Qt.Vertical
        anchors.top: categoryChooser.bottom;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: parent.bottom;

        TableView {
            id: tracksPointTable

            anchors.top: parent.top;
            anchors.left: parent.left;
            anchors.right: parent.right;
            height: parent.height*0.75;

            model: tracksModel;

            selectionMode:SelectionMode.ExtendedSelection;

            itemDelegate: TracksListTableDelegate {
                comboModel: pointsModel
                typeModel: connectionTypeModel
                category_defaults: propsDetail;

                onChangeModel: {
                    tracksModel.setProperty(row, role, value);

                    tracksPointTable.selection.clear();
//                    tracksPointTable.selection.select(row);
//                    tracksPointTable.currentRow = row;

                }

            }

            rowDelegate: Rectangle {
                height: 30;
                color: styleData.selected ? "#0077cc" : (styleData.alternate? "#eee" : "#fff")

            }

            TableViewColumn {
                //% "Id"
                title: qsTrId("tracks-list-id")
                role: "tid"
                width: 50;
            }
            TableViewColumn {
                //% "Point"
                title: qsTrId("tracks-list-point");
                role: "pid"
                width: 250;
            }

            TableViewColumn {
                //% "Type"
                title: qsTrId("tracks-list-type");
                role: "type"
                width: 100;

            }
            TableViewColumn {
                //% "Angle [deg]"
                title: qsTrId("tracks-list-angle")
                role: "angle"
                width: 50;
            }

            TableViewColumn {
                //% "Distance to previous point [m]"
                title: qsTrId("tracks-list-distance")
                role: "distance"
                width: 50;
            }

            TableViewColumn {
                //% "Distance to start point [m]"
                title: qsTrId("tracks-list-distance-sum")
                role: "distance_sum"
                width: 50;
            }

            TableViewColumn {
                //% "Time to next point [s]"
                title: qsTrId("tracks-list-addTime")
                role: "addTime"
                width: 80;
            }


            TableViewColumn {
                //% "Radius [m]"
                title: qsTrId("tracks-list-radius")
                role: "radius"
                width: 50;
            }


            TableViewColumn {
                //% "Flags"
                title: qsTrId("tracks-list-flags")
                role: "flags"
                width: 150;
            }

            TableViewColumn {
                //% "Min Alt [m]"
                title: qsTrId("tracks-list-alt_min")
                role: "alt_min"
                width: 50;
            }
            TableViewColumn {
                //% "Max Alt [m]"
                title: qsTrId("tracks-list-alt_max")
                role: "alt_max"
                width: 50;
                //visible: false;
            }

            TableViewColumn {
                //% "Min Speed [km/h]"
                title: qsTrId("tracks-list-speed_min")
                role: "speed_min"
                width: 50;
                visible: false;
            }
            TableViewColumn {
                //% "Max Speed [km/h]"
                title: qsTrId("tracks-list-speed_max")
                role: "speed_max"
                width: 50;
                visible: false;
            }
            TableViewColumn {
                //% "Arc/Poly"
                title: qsTrId("tracks-list-ptr")
                role: "ptr"
                width: 50;
            }



            MouseArea {
                acceptedButtons: Qt.RightButton
                anchors.fill: parent
                propagateComposedEvents: true
                onClicked: {
                    tracksContextMenu.popup();
                }

            }

            Component.onCompleted: {
                selection.selectionChanged.connect(selectionChangedHanlder);
            }

            function selectionChangedHanlder() {

                if (currentRow < 0) {
                    return;
                }
                if (!tracksPointTable.selection.contains(currentRow)) {
                    return;
                }

                var sel = [];

                var checkedCount = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

                tracksPointTable.selection.forEach( function(rowIndex) {
                    sel.push(rowIndex)

                    var item = model.get(rowIndex);
                    var flags = parseInt(item.flags, 10);
                    if (flags < 0) {
                        flags = parseInt(propsDetail.default_flags, 10)
                    }

                    var arr = F.arrayFromMask(flags | 0x10000);

                    for (var i = 0; i < arr.length; i++) {
                        if (arr[i]) {
                            checkedCount[i] = checkedCount[i] + 1
                        }
                    }

                });

                var sum = tracksPointTable.selection.count;

                menu_tp_cb.checked = checkedCount[0] > 0;
                menu_tg_cb.checked = checkedCount[1] > 0;
                menu_sg_cb.checked = checkedCount[2] > 0;
                menu_alt_min_cb.checked = checkedCount[3] > 0;
                menu_alt_max_cb.checked = checkedCount[4] > 0;
                menu_speed_min_cb.checked = checkedCount[5] > 0;
                menu_speed_max_cb.checked = checkedCount[6] > 0;
                menu_section_speed_start_cb.checked = checkedCount[7] > 0;
                menu_section_speed_end_cb.checked = checkedCount[8] > 0;
                menu_section_alt_start_cb.checked = checkedCount[9] > 0;
                menu_section_alt_end_cb.checked = checkedCount[10] > 0;
                menu_section_space_start_cb.checked = checkedCount[11] > 0;
                menu_section_space_end_cb.checked = checkedCount[12] > 0;
                menu_sectet_turn_point_cb.checked = checkedCount[13] > 0
                menu_sectet_time_gate_cb.checked = checkedCount[14] > 0;
                menu_sectet_space_gate_cb.checked = checkedCount[15] > 0;


                menu_tp_cb.enabled = (checkedCount[0] === 0) || (checkedCount[0] === sum);
                menu_tg_cb.enabled = (checkedCount[1] === 0) || (checkedCount[1] === sum);
                menu_sg_cb.enabled = (checkedCount[2] === 0) || (checkedCount[2] === sum);
                menu_alt_min_cb.enabled = (checkedCount[3] === 0) || (checkedCount[3] === sum);
                menu_alt_max_cb.enabled = (checkedCount[4] === 0) || (checkedCount[4] === sum);
                menu_speed_min_cb.enabled = (checkedCount[5] === 0) || (checkedCount[5] === sum);
                menu_speed_max_cb.enabled = (checkedCount[6] === 0) || (checkedCount[6] === sum);
                menu_section_speed_start_cb.enabled = (checkedCount[7] === 0) || (checkedCount[7] === sum);
                menu_section_speed_end_cb.enabled = (checkedCount[8] === 0) || (checkedCount[8] === sum);
                menu_section_alt_start_cb.enabled = (checkedCount[9] === 0) || (checkedCount[9] === sum);
                menu_section_alt_end_cb.enabled = (checkedCount[10] === 0) || (checkedCount[10] === sum);
                menu_section_space_start_cb.enabled = (checkedCount[11] === 0) || (checkedCount[11] === sum);
                menu_section_space_end_cb.enabled = (checkedCount[12] === 0) || (checkedCount[12] === sum);
                menu_sectet_turn_point_cb.enabled = (checkedCount[13] === 0) || (checkedCount[13] === sum);
                menu_sectet_time_gate_cb.enabled = (checkedCount[14] === 0) || (checkedCount[14] === sum);
                menu_sectet_space_gate_cb.enabled = (checkedCount[15] === 0) || (checkedCount[15] === sum);


                // highlight first one in map
                if (sel.length >0) {
                    var item = model.get(sel[0]);
                    pointSelected(item.tid)
                }

            }

            function switchFlag(flags_index) {

                var sel = [];

                tracksPointTable.selection.forEach( function(rowIndex) {
                    sel.push(rowIndex);

                    var item = model.get(rowIndex);
                    var flags = parseInt(item.flags, 10);
                    if (flags < 0) {
                        flags = parseInt(propsDetail.default_flags, 10)
                    }

                    var mask = (0x1 << flags_index);
                    flags = flags ^ mask
                    tracksModel.setProperty(rowIndex, "flags", flags);


                })



                tracksPointTable.selection.clear();

                for (var i = 0; i < sel.length; i++) {
                    tracksPointTable.selection.select(sel[i]);
                }

            }

            Menu {
                id: tracksContextMenu;

                MenuItem {
                    id: trackListPointsTableAddBeforeMenuItem

                    visible: (tracksPointTable.selection.count > 0) && (tracksModel.count > 0)
                    //% "Add point before selected"
                    text: qsTrId("tracks-list-points-table-add-before")
                    onTriggered: {
                        var firstIndex = 0;
                        var sel = [];
                        tracksPointTable.selection.forEach( function(rowIndex) {
                            sel.push(rowIndex)

                        } )
                        if (sel.length > 0 ) {
                            firstIndex = sel[0];
                        }
                        tracksContextMenu.addPoint(firstIndex)

                    }
                }

                MenuItem {
                    //% "Add point after selected"
                    text: qsTrId("tracks-list-points-table-add-after")
                    visible: trackListPointsTableAddBeforeMenuItem.visible
                    onTriggered: {
                        var lastIndex = 0;
                        tracksPointTable.selection.forEach( function(rowIndex) {
                            lastIndex = rowIndex;
                        } )
                        tracksContextMenu.addPoint(lastIndex+1)
                    }
                }

                MenuItem {
                    //% "Add point"
                    text: qsTrId("tracks-list-points-table-add")
                    enabled: (pointsModel.count > 0)
                    visible: !trackListPointsTableAddBeforeMenuItem.visible

                    onTriggered: {
                        tracksContextMenu.addPoint(-1)
                    }
                }

                MenuItem {
                    //% "Append 10 points"
                    text: qsTrId("tracks-list-points-table-add-10")
                    enabled: (pointsModel.count > 0)

                    onTriggered: {
                        for (var i = 0; i < 10; i++) {
                            tracksContextMenu.addPoint(-1)
                        }
                    }
                }

                function addPoint(pos) {
                    var maxId = 0;
                    for (var i = 0; i < tracksModel.count; i++) {
                        var item = tracksModel.get(i);
                        maxId = Math.max(item.tid, maxId);
                    }
                    var p = pointsModel.get(0);

                    if (tracksModel.count > pos && pos > 0) {
                        var firstTIpid = tracksModel.get(pos).pid
                        var secondTIpid = tracksModel.get(pos-1).pid
                        console.log(firstTIpid + " " + secondTIpid)
                        var firstItem = p;
                        var secondItem = p;

                        for (var j = 0; j < pointsModel.count; j++) {
                            var pitem = pointsModel.get(j)
                            if (pitem.pid === firstTIpid) {
                                console.log("found fisrt" + pitem.name)
                                firstItem = pitem;
                            }
                            if (pitem.pid === secondTIpid) {
                                secondItem = pitem;
                            }
                        }

                        var lat = 0.5 * (firstItem.lat + secondItem.lat)
                        var lon = 0.5 * (firstItem.lon + secondItem.lon)

                        var minDistance = 100000;
                        for (var j = 0; j < pointsModel.count; j++) {
                            pitem = pointsModel.get(j)
                            if (pitem.pid === firstTIpid) {
                                continue
                            }
                            if (pitem.pid === secondTIpid) {
                                continue
                            }
                            var distance = G.getDistanceTo(lat, lon, pitem.lat, pitem.lon)
                            console.log("distance " + pitem.pid + " " + pitem.name + " " + distance)
                            if (distance < minDistance) {
                                minDistance = distance
                                p = pitem;
                            }

                        }
                        console.log("look for point between: " + firstItem.name + " ("+firstItem.pid+")" + secondItem.name + "("+secondItem.pid+") found " + p.name + "(" + p.pid + ")")

                    } else if (tracksModel.count > 0) {
                        // append point with next pid
                        var lastTIpid = tracksModel.get(tracksModel.count-1).pid
                        for (var j = 0; j < pointsModel.count; j++) {
                            pitem = pointsModel.get(j)
                            if (pitem.pid > lastTIpid) {
                                console.log("Appending point pid = " + pitem.pid + ": " + pitem.name)
                                p = pitem;
                                break;
                            }
                        }
                    }

                    var obj = {
                        "tid": (maxId+1),
                        "pid": p.pid,
                        "type": "line",
                        "flags": -1,
                        "distance": -1,
                        "addTime": 0,
                        "computed_angle": -1,
                        "computed_distance": -1,
                        "angle": -1,
                        "radius": -1,
                        "speed_min": -1,
                        "speed_max": -1,
                        "alt_min": -1,
                        "alt_max": -1,
                        "ptr": -1,
                    };

                    if ((pos === -1) || (pos >= tracksModel.count)) {
                        tracksModel.append(obj)
                        tracksPointTable.selection.clear();
//                        tracksPointTable.currentRow = 0;
//                        tracksPointTable.selection.select(0)
                    } else {

                        tracksModel.insert(pos, obj)

                        tracksPointTable.selection.clear();
//                        tracksPointTable.currentRow = pos;
//                        tracksPointTable.selection.select(pos)

                    }

                    tracksModel.tracksChanged();
                }

                MenuItem {
                    //% "Remove point"
                    text: qsTrId("tracks-list-points-table-remove")
                    enabled: ((tracksPointTable.currentRow !== -1) && (tracksModel.count > 0) )

                    onTriggered: {
                        var removedCount = 0;
                        tracksPointTable.selection.forEach( function(rowIndex) {
                            tracksModel.remove(rowIndex-removedCount, 1);
                            removedCount++;
                        })
                        tracksModel.tracksChanged();
                    }
                }

                MenuSeparator {
                    visible: menu_flags_reset.visible
                }
                MenuItem {
                    id: menu_flags_reset

                    visible: ((tracksPointTable.currentRow !== -1) && (tracksModel.count > 0) )
                    //% "Reset flags"
                    text: qsTrId("point-detail-reset-flags");
                    onTriggered: {
                        tracksPointTable.selection.forEach( function(rowIndex) {
                            tracksPointTable.model.setProperty(rowIndex, "flags", -1);
                        });
                        tracksPointTable.selectionChangedHanlder();
                    }

                }

                MenuItem {
                    id: menu_tp_cb
                    visible: menu_flags_reset.visible
                    checkable: true;
                    text: qsTrId("point-detail-turn-point-checkbox");
                    onTriggered: tracksPointTable.switchFlag(0);
                }
                MenuItem {
                    id: menu_tg_cb
                    visible: menu_flags_reset.visible
                    checkable: true;
                    text: qsTrId("point-detail-time-gate-checkbox");
                    onTriggered: tracksPointTable.switchFlag(1);
                }
                MenuItem {
                    id: menu_sg_cb
                    visible: menu_flags_reset.visible
                    checkable: true;
                    text: qsTrId("point-detail-space-gate-checkbox");
                    onTriggered: tracksPointTable.switchFlag(2);
                }

                MenuItem {
                    id: menu_alt_min_cb
                    visible: menu_flags_reset.visible
                    checkable: true;
                    text: qsTrId("point-detail-altitude-min-checkbox");
                    onTriggered: tracksPointTable.switchFlag(3);
                }

                MenuItem {
                    id: menu_alt_max_cb
                    visible: menu_flags_reset.visible
                    checkable: true;
                    text: qsTrId("point-detail-altitude-max-checkbox");
                    onTriggered: tracksPointTable.switchFlag(4);
                }
                Item {
                    visible: false;
                    MenuItem {
                        id: menu_speed_min_cb
                        //                    visible: menu_flags_reset.visible
                        visible: false;
                        checkable: true;
                        text: qsTrId("point-detail-speed-min-checkbox");
                        onTriggered: tracksPointTable.switchFlag(5);
                    }
                    MenuItem {
                        id: menu_speed_max_cb
                        //                    visible: menu_flags_reset.visible
                        visible: false;
                        checkable: true;
                        text: qsTrId("point-detail-speed-max-checkbox");
                        onTriggered: tracksPointTable.switchFlag(6);
                    }
                }

                MenuItem {
                    id: menu_section_speed_start_cb
                    visible: menu_flags_reset.visible
                    checkable: true;
                    text: qsTrId("point-detail-section_speed_start-checkbox");
                    onTriggered: tracksPointTable.switchFlag(7);

                }
                MenuItem {
                    id: menu_section_speed_end_cb
                    visible: menu_flags_reset.visible
                    checkable: true
                    text: qsTrId("point-detail-section_speed_end-checkbox");
                    onTriggered: tracksPointTable.switchFlag(8);

                }
                MenuItem {
                    id: menu_section_alt_start_cb
                    visible: menu_flags_reset.visible
                    checkable: true;
                    text: qsTrId("point-detail-section_alt_start-checkbox");
                    onTriggered: tracksPointTable.switchFlag(9);

                }
                MenuItem {
                    id: menu_section_alt_end_cb
                    visible: menu_flags_reset.visible
                    checkable: true;
                    text: qsTrId("point-detail-section_alt_end-checkbox");
                    onTriggered: tracksPointTable.switchFlag(10);
                }
                MenuItem {
                    id: menu_section_space_start_cb
                    visible: menu_flags_reset.visible
                    checkable: true;
                    text: qsTrId("point-detail-section_space_start-checkbox");
                    onTriggered: tracksPointTable.switchFlag(11);

                }
                MenuItem {
                    id: menu_section_space_end_cb
                    visible: menu_flags_reset.visible
                    checkable: true;
                    text: qsTrId("point-detail-section_space_end-checkbox");
                    onTriggered: tracksPointTable.switchFlag(12);
                }
            }
        }
        Item {
            visible: false;
            enabled: false;

            MenuItem {
                id: menu_sectet_turn_point_cb
                visible: menu_flags_reset.visible
                checkable: true;
                //% "Secret Turn Point"
                text: qsTrId("point-detail-secret_turn_point-checkbox");
                onTriggered: tracksPointTable.switchFlag(13);
            }
            MenuItem {
                id: menu_sectet_time_gate_cb
                visible: menu_flags_reset.visible
                checkable: true;
                text: qsTrId("point-detail-secret_time_gate-checkbox");
                onTriggered: tracksPointTable.switchFlag(14);
            }
            MenuItem {
                id: menu_sectet_space_gate_cb
                visible: menu_flags_reset.visible
                checkable: true;
                text: qsTrId("point-detail-secret_space_gate-checkbox");
                onTriggered: tracksPointTable.switchFlag(15);
            }
        }


        TableView {
            id: polygonsTable
            anchors.left: parent.left;
            anchors.right: parent.right
            anchors.top: tracksPointTable.bottom;
            anchors.bottom: parent.bottom;

            model: selectedPolygonsModel

            rowDelegate: Rectangle {
                height: 30;
                color: styleData.selected ? "#0077cc" : (styleData.alternate? "#eee" : "#fff")

            }

            itemDelegate: TracksListPolygonsDelegate {
                comboModel: allPolygonsModel
                onChangeModel: {
                    if (row >= selectedPolygonsModel.count) {
                        return;
                    }
                    selectedPolygonsModel.setProperty(row, role, value);

                    polygonsTable.selection.clear();
//                    polygonsTable.selection.select(row);
//                    polygonsTable.currentRow = row;

                }

            }

            TableViewColumn {
                //% "Id"
                title: qsTrId("track-list-polygon-did")
                role: "did";
                width: 50;

            }
            TableViewColumn {
                //% "Polygon"
                title: qsTrId("track-list-polygon-cid")
                role: "cid";
                width: 150;
            }
            TableViewColumn {
                //% "Score"
                title: qsTrId("track-list-polygon-score")
                role: "score"
                width: 150;
            }

            MouseArea {
                acceptedButtons: Qt.RightButton
                anchors.fill: parent
                propagateComposedEvents: true
                onClicked: {
                    polyContextMenu.popup();
                }

            }

            Menu {
                id: polyContextMenu;
                MenuItem {
                    //% "Add polygon"
                    text: qsTrId("tracks-list-polygons-table-add")
                    enabled: (allPolygonsModel.count > 0)
                    onTriggered: {
                        var maxId = 0;
                        for (var i = 0; i < selectedPolygonsModel.count; i++) {
                            var item = selectedPolygonsModel.get(i);
                            maxId = Math.max(item.did, maxId);
                        }

                        var polyItem = allPolygonsModel.get(0)
                        var firstCid = polyItem.cid;


                        selectedPolygonsModel.append({
                                                         "did": (maxId+1),
                                                         "cid": firstCid,
                                                         "score": 0
                                                     })
                        selectedPolygonsModel.selectedPolygonsChanged()

                    }
                }
                MenuItem {
                    //% "Remove polygon"
                    text: qsTrId("tracks-list-polygons-table-remove")
                    enabled: ((polygonsTable.selection.count > 0) && (selectedPolygonsModel.count > 0))
                    onTriggered: {
                        polygonsTable.selection.forEach( function(rowIndex) {
                            selectedPolygonsModel.remove(rowIndex, 1)
                        })
                        selectedPolygonsModel.selectedPolygonsChanged();
                    }
                }
            }
        }
    }

}
