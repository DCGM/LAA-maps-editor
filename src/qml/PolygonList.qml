import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
    id: tableView
    property variant polygons

    signal polygonSelected(int cid);

    signal newPolygons(variant p);
    signal polygonToPoints(int cid);

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

    onPolygonsChanged: {
        if (polygons === undefined) {
            return;
        }
        pModel.clear();
        for (var i = 0; i < polygons.length; i++) {
            var p = polygons[i];
            pModel.append({
                              "cid": p.cid,
                              "name": p.name,
                              "color": p.color,
                              "point_count": p.points.length,
                              "points": JSON.stringify(p.points),
                              "closed": p.closed,
                          });
        }
    }

    function polygonSelectionChanged() {
        if (selection.count === 1) {
            selection.forEach( function(rowIndex) {
                var item = pModel.get(rowIndex);
                polygonSelected(item.cid)
            })
        }
    }

    ColorDialog {
        id: colorDialog;
        property int returnRow;

        onAccepted: {
            var col = String(colorDialog.color).substring(1); // Qt6 color returns #AARRGGBB or #RRGGBB
            if (col.length === 8 && col.startsWith("FF")) {
                col = col.substring(2);
            }
            pModel.setProperty(returnRow, "color", col)

            tableView.selection.deselect(0, pModel.count-1);
            tableView.selection.select(returnRow)
        }
    }

    ListModel {
        id: pModel;

        onDataChanged: {
            polygonsChanged()
        }
        function polygonsChanged() {
            var new_arr = [];
            for (var i = 0; i < count; i++) {
                var p = get(i);

                // dohledani "bodu v puvodnich datech (protoze do listmodelu se to nedava)
                var old_pts = JSON.parse(p.points)

                new_arr.push({
                                 "cid": p.cid,
                                 "name": p.name,
                                 "color": p.color,
                                 "points": old_pts,
                                 "closed": p.closed,
                             })
            }
            newPolygons(new_arr)
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
        id: contextMenu
        Action {
            //% "Transform to points"
            text: qsTrId("polygon-list-polygon-to-points")
            enabled: (tableView.selection.count > 0)
            onTriggered: {
                tableView.selection.forEach( function(rowIndex) {
                    var item = pModel.get(rowIndex);
                    polygonToPoints(item.cid)
                })

            }
        }

        Action {
            //% "Remove polygon"
            text: qsTrId("polygon-list-remove-polygon")
            enabled: (tableView.selection.count > 0)
            onTriggered: {
                var removedCount = 0;
                tableView.selection.forEach( function(rowIndex) {
                    pModel.remove(rowIndex-removedCount, 1)
                    removedCount++;

                } )
                tableView.selection.clear();
                pModel.polygonsChanged();
            }
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
                Text { text: qsTrId("polygon-list-id"); Layout.preferredWidth: 50 }
                Text { text: qsTrId("polygon-list-name"); Layout.preferredWidth: 250 }
                Text { text: qsTrId("polygon-list-color"); Layout.preferredWidth: 70 }
                Text { text: qsTrId("polygon-points-count"); Layout.preferredWidth: 50 }
                Text { text: qsTrId("polygon-closed"); Layout.fillWidth: true }
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: pModel
            clip: true

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
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    PolygonListDelegate {
                        Layout.preferredWidth: 50
                        role: "cid"; value: model.cid; row: index
                        selected: selection.contains(index)
                        onChangeModel: (row, role, value) => {
                            var tmpValue = value;
                            if (role == "closed") {
                                tmpValue = (value === "true")
                            }
                            pModel.setProperty(row, role, tmpValue);
                            tableView.selection.deselect(0, pModel.count-1);
                            tableView.selection.select(row)
                        }
                    }
                    PolygonListDelegate {
                        Layout.preferredWidth: 250
                        role: "name"; value: model.name; row: index
                        selected: selection.contains(index)
                        onChangeModel: (row, role, value) => {
                            pModel.setProperty(row, role, value);
                            tableView.selection.deselect(0, pModel.count-1);
                            tableView.selection.select(row)
                        }
                    }
                    PolygonListDelegate {
                        Layout.preferredWidth: 70
                        role: "color"; value: model.color; row: index
                        selected: selection.contains(index)
                        onChangeModel: (row, role, value) => {
                            pModel.setProperty(row, role, value);
                            tableView.selection.deselect(0, pModel.count-1);
                            tableView.selection.select(row)
                        }
                        onOpenColorDialog: (row, prevValue) => {
                            colorDialog.returnRow = row;
                            colorDialog.selectedColor = "#" + prevValue
                            colorDialog.open();
                        }
                    }
                    PolygonListDelegate {
                        Layout.preferredWidth: 50
                        role: "point_count"; value: model.point_count; row: index
                        selected: selection.contains(index)
                    }
                    PolygonListDelegate {
                        Layout.fillWidth: true
                        role: "closed"; value: model.closed; row: index
                        selected: selection.contains(index)
                        onChangeModel: (row, role, value) => {
                            var tmpValue = value;
                            if (role == "closed") {
                                tmpValue = (value === "true" || value === true)
                            }
                            pModel.setProperty(row, role, tmpValue);
                            tableView.selection.deselect(0, pModel.count-1);
                            tableView.selection.select(row)
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        selection.selectionChanged.connect(polygonSelectionChanged);
    }
}
