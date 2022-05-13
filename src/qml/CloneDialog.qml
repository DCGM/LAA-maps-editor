import QtQuick 2.12
import QtQuick.Controls 2.12
import "./components"

ApplicationWindow {
    id: window;
    width: 300;
    height: 450;
    modality: Qt.ApplicationModal

    //% "Clone track to other tracks"
    title: qsTrId("clone-window-title")

    property variant cupData

    signal tracksUpdated(variant t);

    onCupDataChanged: {
        if (cupData === undefined) {
            return;
        }
        sourceCategories.clear();
        destinationCategories.clear();

        var trks = cupData.tracks
        for (var i = 0; i < trks.length; i++) {
            var t = trks[i];
            sourceCategories.append({
                                         "name" : t.name,
                                         "selected": false,
                                     })
            destinationCategories.append({
                                         "name" : t.name,
                                         "selected": false,
                                     })
        }
    }

    ListModel {
        id: sourceCategories;
    }
    ListModel {
        id: destinationCategories;
    }

    ListView {
        id: sourceTable
        anchors.left: parent.left;
        anchors.right: parent.horizontalCenter;
        anchors.top:parent.top;
        anchors.bottom: includePreferences.top;
        model: sourceCategories;
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
            height: 30;
            width: parent.width
            color: model.selected ? "#0077cc" : ((index%2 === 0)? "#eee" : "#fff")

            NativeText {
                text: model.name
                color: model.selected ? "#ffffff" : "#000000"
                anchors.fill: parent;
                horizontalAlignment: "AlignLeft"
                anchors.margins: 5
            }
            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    for (var i = 0; i < sourceCategories.count; i++) {
                        sourceCategories.setProperty(i, "selected", false)
                    }
                    sourceCategories.setProperty(index, "selected", true)
                }
            }
        }

        function getFirstSelected() {
            for (var i = 0; i < sourceCategories.count; i++) {
                if (sourceCategories.get(i).selected) {
                    return i;
                }
            }
            return -1;
        }

        ScrollBar.vertical: ScrollBar {}

    }

    ListView {

        id: destinationTable
        anchors.left: parent.horizontalCenter;
        anchors.right: parent.right;
        anchors.top:parent.top;
        anchors.bottom: includePreferences.top;
        model: destinationCategories;
        clip: true
        focus: true;
        boundsBehavior: Flickable.StopAtBounds

        property int selStart: 0

        function deselect_all() {
            var c = destinationCategories.count;
            if (c > 0) {
                select(0, c-1, false);
            }
        }

        function select(start, end, value) {
            var a = start < end ? start : end;
            var b = start >= end ? start : end;
            for (var i = a; i <= b; i++) {
                var target = (value === -1) ? !destinationCategories.get(i).selected : value;
                destinationCategories.setProperty(i, "selected", target);
            }
        }

        function select_one(i, value) {
            destinationCategories.setProperty(i, "selected", value);
        }

        delegate: Rectangle {
            height: 30;
            width: parent.width
            color: model.selected ? "#0077cc" : ((index%2 === 0)? "#eee" : "#fff")

            NativeText {
                text: model.name
                color: model.selected ? "#ffffff" : "#000000"
                anchors.fill: parent;
                horizontalAlignment: "AlignLeft"
                anchors.margins: 5
            }
            MouseArea {
                anchors.fill: parent;

                id: item_mousearea
                onClicked: {
                    switch(mouse.modifiers){
                    case Qt.ControlModifier:
                        destinationTable.select(destinationTable.selStart, index, true)
                        break;
                    case Qt.ShiftModifier:
                        destinationTable.select_one(index, !selected)
                        destinationTable.selStart=index;
                        break;
                    default:
                        destinationTable.deselect_all();
                        destinationTable.select_one(index, !selected)
                        destinationTable.selStart=index;
                        break;
                    }
                }

            }
        }

        ScrollBar.vertical: ScrollBar {}
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
                var s = sourceTable.getFirstSelected();
                if (s < 0) {
                    console.error("Clone source is not selected")
                    window.close();
                    return;
                }
                var si = sourceCategories.get(s);
                var si_name = si.name;

                var trks = cupData.tracks

                var found = false;
                var src_obj = [];
                for (var i = 0; i < trks.length; i++) {
                    var t = trks[i];

                    if (t.name === si_name) {
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
                    for (var d = 0; d < destinationTable.count; d++) {
                        if (s === d ) {
                            continue;
                        }

                        var di = sourceCategories.get(d)

                        if (!di.selected) {
                            continue;
                        }
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
                                    "speed_max_score": src_obj.speed_max_score,
                                    "speed_penalty": src_obj.speed_penalty,
                                    "speed_tolerance": src_obj.speed_tolerance,
                                    "preparation_time": src_obj.preparation_time,
                                    "default_radius": src_obj.default_radius,
                                    "default_alt_min": src_obj.default_alt_min,
                                    "default_alt_max": src_obj.default_alt_max,
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
                                    "speed_max_score": t.speed_max_score,
                                    "speed_penalty": t.speed_penalty,
                                    "speed_tolerance": t.speed_tolerance,
                                    "preparation_time": t.preparation_time,
                                    "default_radius": t.default_radius,
                                    "default_alt_min": t.default_alt_min,
                                    "default_alt_max": t.default_alt_max,
                                    "default_flags": t.default_flags,
                                }

                            }

                            new_obj.conn = src_obj.conn
                            new_obj.poly = src_obj.poly

                            result.push(new_obj)
                            found = true;
                        }

                    }

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
