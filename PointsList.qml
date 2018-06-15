import QtQuick 2.5
import QtQuick.Controls 1.4

TableView {
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

    model: pModel;
    selectionMode: SelectionMode.ExtendedSelection

    onRowCountChanged: {
        if (lateSelect !== undefined) {
            tableView.selection.clear();
            tableView.selection.select(lateSelect)
            lateSelect = undefined;
        }

    }


    onPointPidSelectedFromMapChanged: {
        for (var i = 0; i < pModel.count; i++) {

            var item = pModel.get(i);
            if (item.pid === pointPidSelectedFromMap) {
                tableView.selection.clear();
                tableView.selection.select(i);
                currentRow =i;
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
                currentRow = i;
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
                pointSelected(model.get(rowIndex).pid);
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




    itemDelegate: PointsListEditableDelegate {
        onChangeModel: {
            tableView.model.setProperty(row, role, value);

            tableView.selection.deselect(0, pModel.count-1);
            tableView.selection.select(row)
            tableView.currentRow = row;

            pointSelected(pModel.get(row).pid);

        }

        onReverseGeocoding: {
            var item = pModel.get(row);

            var url = "http://nominatim.openstreetmap.org/reverse?lat="+item.lat+"&lon="+item.lon+"&format=json";
            var http = new XMLHttpRequest()
            http.open("GET", url, true);
            http.onreadystatechange = function() {
                if (http.readyState === XMLHttpRequest.DONE) {
                    if (http.readyState === XMLHttpRequest.DONE) {
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
                        tableView.selection.deselect(0, pModel.count-1);
                        tableView.selection.select(row)
                        tableView.currentRow = row;

                        pointSelected(pModel.get(row).pid);

                    }
                }
            }
            http.send()
        }
    }

    MouseArea {
        acceptedButtons: Qt.RightButton
        anchors.fill: parent
        propagateComposedEvents: true
        onClicked: {
            contextMenu.popup();
        }

    }

    Menu {
        id: contextMenu;
        MenuItem {
            //% "Add point"
            text: qsTrId("points-list-add-point")
            onTriggered: {
                var maxId = 0;
                for (var i = 0; i < pModel.count; i++) {
                    var item = pModel.get(i);
                    maxId = Math.max(item.pid, maxId);
                }


                pModel.append({
                                  "pid": (maxId+1),
                                  //% "Turn point"
                                  "name": qsTrId("points-list-default-name"),
                                  "lat": mapCenterLat,
                                  "lon": mapCenterLon
                              })

                var current = pModel.count-1;

                pModel.pointsChanged()

                lateSelect = current; // workarround for https://bugreports.qt.io/browse/QTBUG-53027



            }
        }
        MenuItem {
            //% "Remove points"
            text: qsTrId("points-list-remove-points")
            enabled: (tableView.currentRow !== -1)
            onTriggered: {
                var removedCount = 0;
                tableView.selection.forEach(function(rowIndex) {
                    var removeIndex = rowIndex - removedCount;
                    pModel.remove(removeIndex, 1);
                    removedCount++
                })
                tableView.selection.clear();

                pModel.pointsChanged();

            }
        }

        MenuItem {
            //% "Snap to.."
            text: qsTrId("points-list-snap-to")
            enabled: (tableView.currentRow !== -1)
            visible: enableSnap
            onTriggered: {
                var item = pModel.get(tableView.currentRow)
                snapToSth(item.pid)
            }
        }

        MenuItem {
            //% "Transform to polygon"
            text: qsTrId("points-list-transform-to-polygon")
            visible: (tableView.selection.count > 1)
            onTriggered: {
                var newPointsArr = []
                tableView.selection.forEach(function(rowIndex) {
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


    TableViewColumn {
        role: "pid"
        //% "Id"
        title: qsTrId("points-list-id");
        width: 50;
    }

    TableViewColumn {
        role: "name"
        //% "Name"
        title: qsTrId("points-list-name");
        width: 100;
    }

    TableViewColumn {
        role: "lat"
        //% "Latitude"
        title: qsTrId("points-list-lat");
        width: 150;
    }

    TableViewColumn {
        role: "lon"
        //% "Longitude"
        title: qsTrId("points-list-lon");
        width: 150;
    }





}
