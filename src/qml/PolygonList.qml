import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

TableView {
    id: tableView
    property variant polygons

    signal polygonSelected(int cid);

    model: pModel

    signal newPolygons(variant p);
    signal polygonToPoints(int cid);

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
                var item = model.get(rowIndex);
                polygonSelected(item.cid)
            })
        }
    }

    ColorDialog {
        id: colorDialog;
        property int returnRow;

        onAccepted: {
            var col = String(colorDialog.currentColor).substring(1);
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
        MenuItem {
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

        MenuItem {
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

    itemDelegate: PolygonListDelegate {
        onChangeModel: {
            var tmpValue = value;
            if (role == "closed") {
                tmpValue = (value === "true")
            }
            console.log(row + " " + role + " " + tmpValue)
            pModel.setProperty(row, role, tmpValue);
            tableView.selection.deselect(0, pModel.count-1);
            tableView.selection.select(row)

        }

        onOpenColorDialog: {
            colorDialog.returnRow = row;
            colorDialog.color = "#" + prevValue
            colorDialog.open();
        }

    }

    TableViewColumn {
        //% "Id"
        title: qsTrId("polygon-list-id")
        role: "cid"
        width: 50
    }

    TableViewColumn {
        //% "Name"
        title: qsTrId("polygon-list-name");
        role: "name"
        width: 250;
    }

    TableViewColumn {
        //% "Color"
        title: qsTrId("polygon-list-color");
        role: "color";
        width: 70;
    }

    TableViewColumn {
        //% "Points"
        title: qsTrId("polygon-points-count");
        role: "point_count";
        width: 50;
    }
    TableViewColumn {
        //% "Closed"
        title: qsTrId("polygon-closed")
        role: "closed";
        width: 50
    }

    Component.onCompleted: {
        selection.selectionChanged.connect(polygonSelectionChanged);
    }
}
