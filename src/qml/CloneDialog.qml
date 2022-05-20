import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml.Models 2.12
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
        categories.clear();
        sourceCategoriesSelection.clearSelection();

        var trks = cupData.tracks
        for (var i = 0; i < trks.length; i++) {
            var t = trks[i];
            categories.append({"name" : t.name})
        }
    }


    ItemSelectionModel {
        id: sourceCategoriesSelection
        model: categories
    }

    ItemSelectionModel {
        id: destinationCategoriesSelection
        model: categories
    }

    ListModel {
        id: categories;
    }

    ListView {
        id: sourceTable
        anchors.left: parent.left;
        anchors.right: parent.horizontalCenter;
        anchors.top:parent.top;
        anchors.bottom: includePreferences.top;
        model: categories;
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
            height: 30;
            width: parent.width
            property bool selected: sourceCategoriesSelection.hasSelection
                                    && sourceCategoriesSelection.isSelected(categories.index(index, 0))
            color: selected ? "#0077cc" : ((index%2 === 0)? "#eee" : "#fff")

            NativeText {
                text: model.name
                color: selected  ? "#ffffff" : "#000000"
                anchors.fill: parent;
                horizontalAlignment: "AlignLeft"
                anchors.margins: 5
            }
            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    sourceCategoriesSelection.select(categories.index(index,0), ItemSelectionModel.ClearAndSelect)
                }
            }
        }

        ScrollBar.vertical: ScrollBar {}

    }

    ListView {

        id: destinationTable
        anchors.left: parent.horizontalCenter;
        anchors.right: parent.right;
        anchors.top:parent.top;
        anchors.bottom: includePreferences.top;
        model: categories;
        clip: true
        focus: true;
        boundsBehavior: Flickable.StopAtBounds

        property int selStart: 0

        delegate: Rectangle {
            height: 30;
            width: parent.width
            property bool selected: destinationCategoriesSelection.hasSelection
                                    && destinationCategoriesSelection.isSelected(categories.index(index, 0))
            color: selected ? "#0077cc" : ((index%2 === 0)? "#eee" : "#fff")

            NativeText {
                text: model.name
                color: selected ? "#ffffff" : "#000000"
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
                        var a = (destinationTable.selStart < index) ? destinationTable.selStart : index;
                        var b = (destinationTable.selStart >= index) ? destinationTable.selStart : index;
                        for (var i = a; i < b; i++) {
                            destinationCategoriesSelection.select(categories.index(i,0), ItemSelectionModel.Select)
                        }

                        break;
                    case Qt.ShiftModifier:
                        destinationCategoriesSelection.select(categories.index(index, 0), ItemSelectionModel.Select)
                        break;
                    default:
                        destinationCategoriesSelection.select(categories.index(index, 0), ItemSelectionModel.ClearAndSelect)
                        break;
                    }
                    destinationTable.selStart = index
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
                if (!sourceCategoriesSelection.hasSelection) {
                    console.error("Clone source is not selected")
                    window.close();
                    return;
                }
                var si = categories.get(sourceCategoriesSelection.selectedRows(0));
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
                    for (var d = 0; d < categories.count; d++) {
                        var di = categories.get(d)
                        if (si_name === di.name) { // do not try to replace own category
                            continue;
                        }

                        if (!destinationCategoriesSelection.isSelected(categories.index(d, 0))) {
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
