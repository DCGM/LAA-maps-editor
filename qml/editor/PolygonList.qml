import QtQuick 2.2
import QtQuick.Controls 1.2
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
                              "points": JSON.stringify(p.points)
                          });

        }

    }

    onCurrentRowChanged: {
        var item = model.get(currentRow);
        polygonSelected(item.cid)
    }

    ColorDialog {
        id: colorDialog;
        property int returnRow;

        onAccepted: {
            var col = String(color).substring(1);
            pModel.setProperty(returnRow, "color", col)

            tableView.selection.deselect(0, pModel.count-1);
            tableView.selection.select(returnRow)
            tableView.currentRow = returnRow;


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
                                 "points": old_pts
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
            enabled: (tableView.currentRow !== -1)
            onTriggered: {
                var item = pModel.get(tableView.currentRow);
                polygonToPoints(item.cid)

            }
        }

        MenuItem {
            //% "Remove polygon"
            text: qsTrId("polygon-list-remove-polygon")
            enabled: (tableView.currentRow !== -1)
            onTriggered: {
                pModel.remove(tableView.currentRow, 1)
                pModel.polygonsChanged();
            }
        }

    }

    itemDelegate: PolygonListDelegate {
        onChangeModel: {
            tableView.model.setProperty(row, role, value);
            tableView.selection.deselect(0, pModel.count-1);
            tableView.selection.select(row)
            tableView.currentRow = row;

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
        width: 150;
    }

    TableViewColumn {
        //% "Color"
        title: qsTrId("polygon-list-color");
        role: "color";
        width: 100;
    }

    TableViewColumn {
        //% "Points"
        title: qsTrId("polygon-points-count");
        role: "point_count";
        width: 50;
    }
}
