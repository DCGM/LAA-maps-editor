import QtQuick 2.12
import QtQuick.Controls 2.12
import "functions.js" as F
import "./components"


ApplicationWindow {

    id: window;
    //% "Category properties %1"
    title: qsTrId("props-detail").arg(category_name);
    modality: Qt.ApplicationModal

    minimumWidth: 800
    minimumHeight: 600
    width: (leftSide.childrenRect.width + 2* leftSide.anchors.margins + rightSide.childrenRect.width + 2* rightSide.anchors.margins);
    height: Math.max(leftSide.childrenRect.height + 2* leftSide.anchors.margins, rightSide.childrenRect.height + 2* rightSide.anchors.margins)


    signal accepted();
    signal canceled();

    property string category_name: ""
    property alias tg_max_score: tg_max_score_textfield.value;
    property alias tg_tolerance: tg_tolerance_textfield.value;
    property alias tg_penalty: tg_penalty_textfield.value;
    property alias sg_max_score: sg_max_score_textfield.value;
    property alias tp_max_score: tp_max_score_textfield.value;
    property alias marker_max_score: marker_max_score_textfield.value;
    property alias photos_max_score: photos_max_score_textfield.value;
    property alias time_window_size: time_window_size_textfield.value;
    property alias time_window_penalty: time_window_penalty_textfield.value;
    property alias alt_penalty: alt_penalty_textfield.value;
    property alias gyre_penalty: gyre_penalty_textfield.value;
    property alias oposite_direction_penalty: oposite_direction_penalty_textfield.value;
    property alias out_of_sector_penalty: out_of_sector_penalty_textfield.value;
    property alias speed_max_score: speed_max_score_textfield.value;
    property alias speed_penalty: speed_penalty_textfield.value;
    property alias speed_tolerance: speed_tolerance_textfield.value;
    property alias preparation_time: preparation_time_textfield.seconds

    // vychozi hodnoty
    property alias default_radius: default_radius_textfield.value;
    property alias default_alt_min: default_alt_min_textfield.value;
    property alias default_alt_max: default_alt_max_textfield.value;
    property int default_flags


    function updateDefaultFlagsIndex(flag_index, value) {
        var mask = (0x1 << flag_index);
        return updateDefaultFlags(mask, value)
    }


    function updateDefaultFlags(mask, value) {
        if (value) {
            default_flags = default_flags | mask;
        } else {
            default_flags = default_flags & ~mask;
        }

    }

    onDefault_flagsChanged: {
        var arr = F.arrayFromMask(default_flags | 0x10000); // 0x10000 je vetsi nez max, aby vzniklo pole o velikosti 10
        tp_cb.checked         = arr[0]
        tg_cb.checked         = arr[1]
        sg_cb.checked         = arr[2]
        alt_min_cb.checked    = arr[3]
        alt_max_cb.checked    = arr[4]

        section_speed_start_cb.checked = arr[7];
        section_speed_end_cb.checked = arr[8];
        section_alt_start_cb.checked = arr[9];
        section_alt_end_cb.checked = arr[10];
        section_space_start_cb.checked = arr[11]
        section_space_end_cb.checked = arr[12]

        secret_turn_point_cb.checked = arr[13];
        secret_time_gate_cb.checked = arr[14];
        secret_space_gate_cb.checked = arr[15];

    }





    Grid {
        id: leftSide
        anchors.left: parent.left;
        anchors.top: parent.top;
        anchors.bottom: buttonsRow.top
        anchors.right: parent.horizontaCenter
        anchors.margins: 10;
        spacing: 5;
        columns: 2;
        NativeText {
            //% "Time gate max score [points]"
            text: qsTrId("props-detail-tg-max-score")
        }
        TextFieldNumber {
            id: tg_max_score_textfield
        }

        NativeText {
            //% "Time gate tolerance [sec]"
            text: qsTrId("props-detail-tg-tolerance")
        }
        TextFieldNumber {
            id: tg_tolerance_textfield;
        }

        NativeText {
            //% "Time gate penalty [points per sec]"
            text: qsTrId("props-detail-tg-penalty")
        }
        TextFieldNumber {
            id: tg_penalty_textfield
        }

        NativeText {
            //% "Space gate max score [points]"
            text: qsTrId("props-detail-sg-max-score")
        }

        TextFieldNumber {
            id: sg_max_score_textfield
        }

        NativeText {
            //% "Turn point max score [points]"
            text: qsTrId("props-detail-tp-max-score")
        }

        TextFieldNumber {
            id: tp_max_score_textfield
        }

        NativeText {
            //% "Marker max score [points]"
            text: qsTrId("props-detail-marker-max-score")
        }
        TextFieldNumber {
            id: marker_max_score_textfield
        }

        NativeText {
            //% "Photos max score [points]"
            text: qsTrId("props-detail-photos-max-score")
        }
        TextFieldNumber {
            id: photos_max_score_textfield
        }

        NativeText {
            //% "Time window size [sec]"
            text: qsTrId("props-detail-time-window-size")
        }
        TextFieldNumber {
            id: time_window_size_textfield
        }

        NativeText {
            //% "Time window penalty [%]"
            text: qsTrId("props-detail-time-window-penalty")
        }
        TextFieldNumber {
            id: time_window_penalty_textfield
        }

        NativeText {
            //% "Altitude penalty [points per meter]"
            text: qsTrId("props-detail-alt-penalty")
        }
        TextFieldNumber {
            id: alt_penalty_textfield
        }

        NativeText {
            //% "Gyre penalty [%]"
            text: qsTrId("props-detail-gyre-penalty")
        }
        TextFieldNumber {
            id: gyre_penalty_textfield
        }

        NativeText {
            //% "Oposite direction penalty [%]"
            text: qsTrId("props-detail-oposite-direction-penalty")
        }
        TextFieldNumber {
            id: oposite_direction_penalty_textfield
        }

        NativeText {
            //% "Out of sector pentaly [%]"
            text: qsTrId("props-detail-out-of-sector-penalty")
        }

        TextFieldNumber {
            id: out_of_sector_penalty_textfield
        }


        NativeText {
            //% "Speed max score [points]"
            text: qsTrId("props-detail-speed-max-score")
        }
        TextFieldNumber {
            id: speed_max_score_textfield
        }


        NativeText {
            //% "Speed penalty [points per km/h]"
            text: qsTrId("props-detail-speed-penalty")
        }
        TextFieldNumber {
            id: speed_penalty_textfield
        }

        NativeText {
            //% "Speed tolerance [km/h]"
            text: qsTrId("props-detail-speed-tolerance")
        }
        TextFieldNumber {
            id: speed_tolerance_textfield
        }

        NativeText {
            //% "Preparation time [hh:mm:ss]"
            text: qsTrId("props-detail-preparation-time");
        }
        TextField {
            id: preparation_time_textfield
            property string seconds
            text: F.addTimeStrFormat(seconds);
            validator: RegExpValidator { regExp: /^(\d+):(\d+):(\d+)$/; }



            function strToAddTime(value) {

                var regexp = /^(\d+):(\d+):(\d+)$/;
                var result = regexp.exec(value);
                if (result) {
                    return parseInt(result[1], 10) * 3600 + parseInt(result[2], 10) * 60 + parseInt(result[3], 10);
                } else {
                    var num = parseFloat(value);
                    if (isNaN(num)) {
                        return 0;
                    } else {
                        return num
                    }
                }
            }

            onAccepted: {
                preparation_time_textfield.seconds = strToAddTime(preparation_time_textfield.text)
            }

            onFocusChanged: {
                preparation_time_textfield.seconds = strToAddTime(preparation_time_textfield.text)
            }

            onEditingFinished: {
                preparation_time_textfield.seconds = strToAddTime(preparation_time_textfield.text)
            }
        }

    }

    Grid {
        id: rightSide
        anchors.right: parent.right;
        anchors.left: parent.horizontalCenter;
        anchors.top: parent.top;
        anchors.bottom: buttonsRow.top;
        anchors.margins: 10;
        spacing: 5;
        columns: 2;


        NativeText {
            //% "Radius [m]"
            text: qsTrId("props-detail-default_radius")
        }

        TextFieldNumber {
            id: default_radius_textfield
        }


        NativeText {
            //% "Minimum Altitude [m]"
            text: qsTrId("props-detail-default_alt_min")
        }

        TextFieldNumber {
            id: default_alt_min_textfield
        }

        NativeText {
            //% "Maximum Altitude [m]"
            text: qsTrId("props-detail-default_alt_max")
        }

        TextFieldNumber {
            id: default_alt_max_textfield
        }


        NativeText {
            //% "Flags"
            text: qsTrId("props-detail-default_flags")
        }

        TextField {
            id: default_flags_textfield
            enabled: false;
            text: default_flags

        }


        NativeText { text: " " }
        CheckBox {
            id: tp_cb;
            //% "Turn Point"
            text: qsTrId("point-detail-turn-point-checkbox");
            onCheckedChanged: updateDefaultFlagsIndex(0, checked);
        }

        NativeText { text: " " }
        CheckBox {
            id: tg_cb;
            //% "Time gate"
            text: qsTrId("point-detail-time-gate-checkbox");
            onCheckedChanged: updateDefaultFlagsIndex(1, checked);
        }

        NativeText { text: " " }
        CheckBox {
            id: sg_cb;
            //% "Space gate"
            text: qsTrId("point-detail-space-gate-checkbox");
            onCheckedChanged: updateDefaultFlagsIndex(2, checked);
        }


        NativeText { text: " " }
        CheckBox {
            id: alt_min_cb;
            //% "Altitude min"
            text: qsTrId("point-detail-altitude-min-checkbox");
            onCheckedChanged: updateDefaultFlagsIndex(3, checked);
        }

        NativeText { text: " " }

        CheckBox {
            id: alt_max_cb;
            //% "Altitude max"
            text: qsTrId("point-detail-altitude-max-checkbox");
            onCheckedChanged: updateDefaultFlagsIndex(4, checked);
        }


        NativeText { text: " " }
        CheckBox {
            id: section_speed_start_cb;
            //% "Section speed start"
            text: qsTrId("point-detail-section_speed_start-checkbox");
            onCheckedChanged: updateDefaultFlagsIndex(7, checked);
        }

        NativeText { text: " " }
        CheckBox {
            id: section_speed_end_cb;
            //% "Section speed end"
            text: qsTrId("point-detail-section_speed_end-checkbox");
            onCheckedChanged: updateDefaultFlagsIndex(8, checked);
        }

        NativeText { text: " " }
        CheckBox {
            id: section_alt_start_cb;
            //% "Section alt start"
            text: qsTrId("point-detail-section_alt_start-checkbox");
            onCheckedChanged: updateDefaultFlagsIndex(9, checked);
        }

        NativeText { text: " " }
        CheckBox {
            id: section_alt_end_cb;
            //% "Section alt end"
            text: qsTrId("point-detail-section_alt_end-checkbox");
            onCheckedChanged: updateDefaultFlagsIndex(10, checked);
        }

        NativeText { text: " " }
        CheckBox {
            id: section_space_start_cb;
            //% "Section space start"
            text: qsTrId("point-detail-section_space_start-checkbox");
            onCheckedChanged: updateDefaultFlagsIndex(11, checked);
        }

        NativeText { text: " " }
        CheckBox {
            id: section_space_end_cb;
            //% "Section space end"
            text: qsTrId("point-detail-section_space_end-checkbox");
            onCheckedChanged: updateDefaultFlagsIndex(12, checked);
        }




        NativeText { text: " "; visible: false;}
        CheckBox {
            visible: false;
            id: secret_turn_point_cb;
            //% "Secret Turn Point"
            text: qsTrId("point-detail-secret_turn_point-checkbox");
            onCheckedChanged: updateDefaultFlagsIndex(13, checked);
        }

        NativeText { text: " ";  visible: false; }
        CheckBox {
            visible: false;
            id: secret_time_gate_cb;
            //% "Secret Time Gate"
            text: qsTrId("point-detail-secret_time_gate-checkbox");
            onCheckedChanged: updateDefaultFlagsIndex(14, checked);
        }

        NativeText { text: " ";  visible: false; }
        CheckBox {
            visible: false;
            id: secret_space_gate_cb;
            //% "Secret Space Gate"
            text: qsTrId("point-detail-secret_space_gate-checkbox");
            onCheckedChanged: updateDefaultFlagsIndex(15, checked);
        }


    }

    onVisibleChanged: {
        preparation_time_textfield.seconds = preparation_time_textfield.strToAddTime(preparation_time_textfield.text)
    }



    Row {
        id: buttonsRow;
        anchors.bottom: parent.bottom;
        anchors.right: parent.right;
        anchors.margins: 10;
        spacing: 5;

        Button {
            //% "Ok"
            text: qsTrId("props-detail-ok")
            onClicked: {
                window.visible = false; // onVisibleChanged
                accepted();
            }
        }

        Button {
            //% "Cancel"
            text: qsTrId("props-detail-cancel");
            onClicked: {
                window.visible = false;
                canceled();
            }
        }
    }





}

