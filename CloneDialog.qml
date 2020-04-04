import QtQuick 2.9
import QtQuick.Controls 1.4

ApplicationWindow {
    id: window;
    width: 300;
    height: 450;
    modality: "ApplicationModal"

    //% "Clone track to other tracks"
    title: qsTrId("clone-window-title")

    property variant cupData

    signal tracksUpdated(variant t);

    onCupDataChanged: {
        if (cupData === undefined) {
            return;
        }
        categoryListModel.clear();

        var trks = cupData.tracks
        for (var i = 0; i < trks.length; i++) {
            var t = trks[i];
            categoryListModel.append({
                                         "name" : t.name
                                     })
        }
    }

    ListModel {
        id: categoryListModel;
    }

    TableView {
        id: sourceTable
        anchors.left: parent.left;
        anchors.right: parent.horizontalCenter;
        anchors.top:parent.top;
        anchors.bottom: includePreferences.top;
        model: categoryListModel;

        rowDelegate: Rectangle {
            height: 30;
            color: styleData.selected ? "#0077cc" : (styleData.alternate? "#eee" : "#fff")

        }


        //        headerVisible: false;
        TableViewColumn {
            //% "Source"
            title: qsTrId("clone-window-source-table-name")
            role: "name"
            width: sourceTable.width
        }
    }

    TableView {

        id: destinationTable
        anchors.left: parent.horizontalCenter;
        anchors.right: parent.right;
        anchors.top:parent.top;
        anchors.bottom: includePreferences.top;
        model: categoryListModel;
        selectionMode: SelectionMode.ExtendedSelection

        rowDelegate: Rectangle {
            height: 30;
            color: styleData.selected ? "#0077cc" : (styleData.alternate? "#eee" : "#fff")

        }

        //        headerVisible: false;
        TableViewColumn {
            //% "Destination"
            title: qsTrId("clone-window-destination-table-name")
            role: "name"
            width: destinationTable.width
        }

    }

    CheckBox {
        id: includePreferences;
        anchors.bottom: buttonsRow.top
        anchors.left: parent.left;
        anchors.leftMargin: 3;
        anchors.right: parent.right;
        //% "Including preferences"
        text: qsTrId("clone-window-include-preferences")
    }

    Row {
        id: buttonsRow;
        anchors.right: parent.right
        anchors.bottom: parent.bottom;
        anchors.margins: 5;
        spacing: 5
        Button {
            //% "Ok"
            text: qsTrId("clone-dialog-ok");
            onClicked: {
                var s = sourceTable.currentRow;
                if (s < 0) {
                    console.log("Error: source is not selected")
                    window.close();
                    return;
                }
                var si = categoryListModel.get(s);
                var si_name = si.name;


                var trks = cupData.tracks

                var found = false;
                var src_obj = [];
                for (var i = 0; i < trks.length; i++) {
                    var t = trks[i];

                    if (t.name == si_name) {
                        found = true;
                        src_obj = t;
                        break;
                    }

                }

                if (!found) {
                    console.log("this shouldn't happen - source object not found")
                    return;
                }

                var result = [];

                for (var i = 0; i < trks.length; i++) {
                    var t = trks[i];
                    var tname = t.name;

                    var found = false;
                    destinationTable.selection.forEach( function(d) {
                        if (s === d ) {
                            return;
                        }

                        var di = categoryListModel.get(d)
                        if (tname === di.name) {
                            if (includePreferences.checked) {
                                var new_obj = {
                                    "name": t.name,
                                    "tg_max_score": src_obj.tg_max_score,
                                    "tg_tolerance": src_obj.tg_tolerance,
                                    "tg_penalty": src_obj.tg_penalty,
                                    "sg_max_score": src_obj.sg_max_score,
                                    "tp_max_score": src_obj.tp_max_score,
                                    "marker_max_score": src_obj.marker_max_score,
                                    "photos_max_score": src_obj.photos_max_score,
                                    "time_window_size": src_obj.time_window_size,
                                    "time_window_penalty": src_obj.time_window_penalty,
                                    "alt_penalty": src_obj.alt_penalty,
                                    "gyre_penalty": src_obj.gyre_penalty,
                                    "oposite_direction_penalty": src_obj.oposite_direction_penalty,
                                    "out_of_sector_penalty": src_obj.out_of_sector_penalty,
                                    "speed_penalty": src_obj.speed_penalty,
                                    "speed_tolerance": src_obj.speed_tolerance,
                                    "preparation_time": src_obj.preparation_time,
                                    "default_radius": src_obj.default_radius,
                                    "default_alt_min": src_obj.default_alt_min,
                                    "default_alt_max": src_obj.default_alt_max,
                                    "default_speed_min": src_obj.default_speed_min,
                                    "default_speed_max": src_obj.default_speed_max,
                                    "default_flags": src_obj.default_flags,
                                }
                            } else {
                                var new_obj = {
                                    "name": t.name,
                                    "tg_max_score": t.tg_max_score,
                                    "tg_tolerance": t.tg_tolerance,
                                    "tg_penalty": t.tg_penalty,
                                    "sg_max_score": t.sg_max_score,
                                    "tp_max_score": t.tp_max_score,
                                    "marker_max_score": t.marker_max_score,
                                    "photos_max_score": t.photos_max_score,
                                    "time_window_size": t.time_window_size,
                                    "time_window_penalty": t.time_window_penalty,
                                    "alt_penalty": t.alt_penalty,
                                    "gyre_penalty": t.gyre_penalty,
                                    "oposite_direction_penalty": t.oposite_direction_penalty,
                                    "out_of_sector_penalty": t.out_of_sector_penalty,
                                    "speed_penalty": t.speed_penalty,
                                    "speed_tolerance": t.speed_tolerance,
                                    "preparation_time": t.preparation_time,
                                    "default_radius": t.default_radius,
                                    "default_alt_min": t.default_alt_min,
                                    "default_alt_max": t.default_alt_max,
                                    "default_speed_min": t.default_speed_min,
                                    "default_speed_max": t.default_speed_max,
                                    "default_flags": t.default_flags,
                                }

                            }

                            new_obj.conn = src_obj.conn
                            new_obj.poly = src_obj.poly

                            result.push(new_obj)
                            found = true;
                        }

                    })

                    if (!found) {
                        result.push(t)
                    }

                }
                tracksUpdated(result);

                window.close();
            }
        }

        Button {
            //% "Cancel"
            text: qsTrId("clone-dialog-cancel");
            onClicked: {
                window.close();
            }
        }
    }


}
