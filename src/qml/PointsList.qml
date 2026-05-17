import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "geom.js" as G

Item {
    id: tableView

    property variant points
    signal newPoints(variant p);
    signal newPolygon(variant p);
    signal pointSelected(int pid);
    signal snapToSth(int pid);
    property int pointPidSelectedFromMap
    property variant newPointPosition;
    property real mapCenterLat: 49
    property real mapCenterLon: 16
    property bool enableSnap: false;
    property variant lateSelect;

    property int currentRow: listView.currentIndex

    QtObject {
        id: selectionData
        property var items: []
        property int count: items.length
        function clear() { items = []; itemsChanged(); }
        function select(idx) { 
            var newItems = items.slice();
            if (newItems.indexOf(idx) === -1) { 
                newItems.push(idx); 
                items = newItems; 
            } 
        }
        function deselect(start, end) { 
            var newItems = [];
            for (var i = 0; i < items.length; i++) {
                if (items[i] < start || items[i] > end) {
                    newItems.push(items[i]);
                }
            }
            items = newItems;
        }
        function forEach(cb) { items.forEach(cb); }
        function contains(idx) { return items.indexOf(idx) !== -1; }
        signal selectionChanged()
        onItemsChanged: selectionChanged()
    }
    property alias selection: selectionData

    onPointPidSelectedFromMapChanged: {
        for (var i = 0; i < pModel.count; i++) {
            var item = pModel.get(i);
            if (item.pid === pointPidSelectedFromMap) {
                selection.clear();
                selection.select(i);
                listView.currentIndex = i;
            }
        }
    }

    onNewPointPositionChanged: {
        if (newPointPosition === undefined) {
            return;
        }
        var pid = newPointPosition.pid
        if (pid === undefined) {
            return;
        }

        for (var i = 0; i < pModel.count; i++) {
            var item = pModel.get(i);
            if (item.pid === pid) {
                pModel.setProperty(i, "lat", newPointPosition.lat)
                pModel.setProperty(i, "lon", newPointPosition.lon)
                listView.currentIndex = i;
                return;
            }
        }
    }

    Component.onCompleted: {
        selection.selectionChanged.connect(pointlistSelectionChanged);
    }

    function pointlistSelectionChanged() {
        if (selection.count === 1) {
            selection.forEach( function(rowIndex) {
                pointSelected(pModel.get(rowIndex).pid);
            });
        }
    }

    onPointsChanged: {
        if (points !== undefined) {
            pModel.clear()
            for (var i = 0; i < points.length; i++) {
                var p = points[i];
                pModel.append({
                                  "pid": p.pid,
                                  "name": p.name,
                                  "lat": parseFloat(p.lat),
                                  "lon": parseFloat(p.lon)
                              })
            }
        }
    }

    function startReverseGeocoding(row) {
        var item = pModel.get(row);

        var url = "https://nominatim.openstreetmap.org/reverse?lat="+item.lat+"&lon="+item.lon+"&format=json";
        console.log(url)
        var http = new XMLHttpRequest()
        http.open("GET", url, true);
        http.onreadystatechange = function() {
            if (http.readyState === XMLHttpRequest.DONE) {
                if (http.readyState === XMLHttpRequest.DONE) {
                    try {
                        var response = JSON.parse(http.responseText)

                        if (response.address === undefined) {
                            return;
                        }
                        if (response.address.city !== undefined) {
                            pModel.setProperty(row, "name", response.address.city);
                        } else if (response.address.town !== undefined) {
                            pModel.setProperty(row, "name", response.address.town);
                        } else if (response.address.hamlet !== undefined) {
                            pModel.setProperty(row, "name", response.address.hamlet);
                        } else if (response.address.village !== undefined) {
                            pModel.setProperty(row, "name", response.address.village);
                        }
                        selection.deselect(0, pModel.count-1);
                        selection.select(row)
                        listView.currentIndex = row;

                        pointSelected(pModel.get(row).pid);
                    } catch (e) {
                        console.error(e + " \"" + http.responseText + "\"")
                    }

                }
            }
        }
        http.send()
    }

    MouseArea {
        acceptedButtons: Qt.RightButton
        anchors.fill: parent
        propagateComposedEvents: true
        onClicked: {
            contextMenu.popup();
        }
    }

    function addPointToList(name = 'point', lat, lon) {
        var maxId = 0;
        for (var i = 0; i < pModel.count; i++) {
            var item = pModel.get(i);
            maxId = Math.max(item.pid, maxId);
        }

        var item = {
            "pid": (maxId+1),
            "name": name,
            "lat": lat,
            "lon": lon
        }

        pModel.append(item)
    }

    Menu {
        id: contextMenu;

        Action {
            //% "Add point"
            text: qsTrId("points-list-add-point")
            onTriggered: {
                var name = qsTrId("points-list-default-name");

                addPointToList(name, mapCenterLat, mapCenterLon)
                var current = pModel.count-1;
                pModel.pointsChanged()
                
                selection.clear();
                selection.select(current);
                listView.currentIndex = current;
            }
        }
        MenuItem {
            //% "Add circle"
            text: qsTrId("points-list-add-circle")
            visible: (tableView.currentRow !== -1)
            height: visible ? implicitHeight : 0
            onTriggered: circleParamDialog.show();
        }

        MenuItem {
            //% "Add points (in line)"
            text: qsTrId("points-list-add-line")
            visible: (tableView.currentRow !== -1)
            height: visible ? implicitHeight : 0
            onTriggered: lineParamDialog.show();
        }

        Action {
            //% "Remove points"
            text: qsTrId("points-list-remove-points")
            enabled: (tableView.currentRow !== -1)
            onTriggered: {
                var removedCount = 0;
                var sortedItems = selection.items.slice().sort(function(a, b){return a - b});
                sortedItems.forEach(function(rowIndex) {
                    var removeIndex = rowIndex - removedCount;
                    pModel.remove(removeIndex, 1);
                    removedCount++
                })
                selection.clear();

                pModel.pointsChanged();

            }
        }

        MenuItem {
            //% "Snap to.."
            text: qsTrId("points-list-snap-to")
            enabled: (selection.count === 1)
            visible: enableSnap
            height: visible ? implicitHeight : 0
            onTriggered: {
                selection.forEach(function(rowIndex) {
                    var item = pModel.get(rowIndex)
                    snapToSth(item.pid)
                    console.log("Snap to: (" +item.pid + ") " + item.name)
                })
            }
        }

        MenuItem {
            //% "Transform to polygon"
            text: qsTrId("points-list-transform-to-polygon")
            visible: (selection.count > 1)
            height: visible ? implicitHeight : 0

            onTriggered: {
                var newPointsArr = []
                selection.forEach(function(rowIndex) {
                    var item = pModel.get(rowIndex)
                    newPointsArr.push({"lat": item.lat, "lon": item.lon})
                })
                var newPolyData = {
                    "cid": -1,
                    "name": qsTrId("polygon-list-default-name"),
                    "color": "FF0000",
                    "points": newPointsArr,
                    "closed": false,
                }
                newPolygon(newPolyData)
            }
        }

        MenuItem {
            //% "Retrieve local name"
            text: qsTrId("points-list-reverse-geocoding")
            visible: (selection.count > 0) && (selection.count <= 3)
            height: visible ? implicitHeight : 0
            onTriggered: {
                selection.forEach(function(rowIndex) {
                    tableView.startReverseGeocoding(rowIndex);
                })
            }
        }
    }

    ListModel {
        id: pModel;
        onDataChanged: {
            pointsChanged();
        }

        function pointsChanged() {
            var new_arr = [];
            for (var i = 0; i < count; i++) {
                var p = get(i);
                new_arr.push({
                                 "pid": p.pid,
                                 "name": p.name,
                                 "lat": parseFloat(p.lat),
                                 "lon": parseFloat(p.lon),

                             })
            }
            newPoints(new_arr);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            height: 30
            color: "#eee"
            RowLayout {
                anchors.fill: parent
                Text { text: qsTrId("points-list-id"); Layout.preferredWidth: 50 }
                Text { text: qsTrId("points-list-name"); Layout.preferredWidth: 200 }
                Text { text: qsTrId("points-list-lat"); Layout.preferredWidth: 150 }
                Text { text: qsTrId("points-list-lon"); Layout.fillWidth: true }
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: pModel
            clip: true

            onCountChanged: {
                if (lateSelect !== undefined) {
                    selection.clear();
                    selection.select(lateSelect)
                    listView.currentIndex = lateSelect;
                    lateSelect = undefined;
                }
            }

            delegate: Rectangle {
                width: listView.width
                height: 30
                color: selection.contains(index) ? "#0077cc" : (index % 2 == 0 ? "#fff" : "#f5f5f5")
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: (mouse) => {
                        if (mouse.modifiers & Qt.ControlModifier) {
                            if (selection.contains(index)) {
                                var newItems = selection.items.filter(i => i !== index);
                                selection.items = newItems;
                            } else {
                                selection.select(index);
                            }
                        } else {
                            selection.clear();
                            selection.select(index);
                            listView.currentIndex = index;
                        }
                        pointSelected(model.pid);
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    PointsListEditableDelegate {
                        Layout.preferredWidth: 50
                        role: "pid"; value: model.pid; row: index
                        selected: selection.contains(index)
                        onChangeModel: (row, role, value) => { pModel.setProperty(row, role, value); }
                    }
                    PointsListEditableDelegate {
                        Layout.preferredWidth: 200
                        role: "name"; value: model.name; row: index
                        selected: selection.contains(index)
                        onChangeModel: (row, role, value) => { pModel.setProperty(row, role, value); }
                    }
                    PointsListEditableDelegate {
                        Layout.preferredWidth: 150
                        role: "lat"; value: model.lat; row: index
                        selected: selection.contains(index)
                        onChangeModel: (row, role, value) => { pModel.setProperty(row, role, value); }
                    }
                    PointsListEditableDelegate {
                        Layout.fillWidth: true
                        role: "lon"; value: model.lon; row: index
                        selected: selection.contains(index)
                        onChangeModel: (row, role, value) => { pModel.setProperty(row, role, value); }
                    }
                }
            }
        }
    }

    CircleParamDialog {
        id: circleParamDialog
        onAccepted: {
            var selectedPoint = pModel.get(tableView.currentRow)
            var radius_num = parseFloat(radius)
            var points_num = parseFloat(points)
            console.log(radius_num + " " + points_num)

            var list = G.insertMidArcByAngle(selectedPoint.lat, selectedPoint.lon, 0, Math.PI*2, true, G.distToAngle(radius_num), (Math.PI*2)/(points_num+0.01));
            for (var i = 0; i < list.length; i++) {
                var name = selectedPoint.name + ": " + qsTrId("points-list-circle-point-name", i+1)
                var coord = list[i];
                addPointToList(name, coord[0], coord[1])
            }
            pModel.pointsChanged()
        }
    }

    LineParamDialog {
        id: lineParamDialog
        onAccepted: {
            var selectedPoint = pModel.get(tableView.currentRow)
            var distance_num = parseFloat(distance)
            var angle_num = parseFloat(angle)
            var points_num = parseFloat(points)
            var distance_sum = 0
            console.log("Add points for line: " + distance_num + " " + angle_num + " " + points_num)

            for (var i = 0; i < points_num; i++) {
                var name = selectedPoint.name + ": " + qsTrId("points-list-line-point-name", i+1)
                distance_sum = distance_sum + distance_num;
                var coord = G.getCoordByDistanceBearing(selectedPoint.lat, selectedPoint.lon, angle_num, distance_sum)
                addPointToList(name, coord.lat, coord.lon)
            }
            pModel.pointsChanged()
        }
    }
}
