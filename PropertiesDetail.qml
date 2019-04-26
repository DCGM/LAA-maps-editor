import QtQuick 2.9
import QtQuick.Controls 1.4
import "functions.js" as F


ApplicationWindow {

    id: window;
    //% "Category properties %1"
    title: qsTrId("props-detail").arg(category_name);
    modality: "ApplicationModal"
    width: 850;
    height: 500;


    signal accepted();
    signal canceled();

    property string category_name: ""
    property alias tg_max_score: tg_max_score_textfield.text;
    property alias tg_tolerance: tg_tolerance_textfield.text;
    property alias tg_penalty: tg_penalty_textfield.text;
    property alias sg_max_score: sg_max_score_textfield.text;
    property alias tp_max_score: tp_max_score_textfield.text;
    property alias marker_max_score: marker_max_score_textfield.text;
    property alias photos_max_score: photos_max_score_textfield.text;
    property alias time_window_size: time_window_size_textfield.text;
    property alias time_window_penalty: time_window_penalty_textfield.text;
    property alias alt_penalty: alt_penalty_textfield.text;
    property alias gyre_penalty: gyre_penalty_textfield.text;
    property alias oposite_direction_penalty: oposite_direction_penalty_textfield.text;
    property alias out_of_sector_penalty: out_of_sector_penalty_textfield.text;
    property alias speed_penalty: speed_penalty_textfield.text
    property alias speed_tolerance: speed_tolerance_textfield.text
    property alias preparation_time: preparation_time_textfield.seconds

    // vychozi hodnoty
    property alias default_radius: default_radius_textfield.text
    property alias default_alt_min: default_alt_min_textfield.text
    property alias default_alt_max: default_alt_max_textfield.text
    //    property alias default_speed_min: default_speed_min_textfield.text
    //    property alias default_speed_max: default_speed_max_textfield.text
    property string default_speed_min: ""
    property string default_speed_max: ""
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
        speed_min_cb.checked  = arr[5]
        speed_max_cb.checked  = arr[6]

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
        anchors.left: parent.left;
        anchors.top: parent.top;
        anchors.bottom: buttonsRow.top
        anchors.right: rightSide.left
        anchors.margins: 10;
        spacing: 5;
        columns: 2;
        NativeText {
            //% "Time gate max score [points]"
            text: qsTrId("props-detail-tg-max-score")
        }
        TextField {
            id: tg_max_score_textfield
        }

        NativeText {
            //% "Time gate tolerance [sec]"
            text: qsTrId("props-detail-tg-tolerance")
        }
        TextField{
            id: tg_tolerance_textfield;
        }

        NativeText {
            //% "Time gate penalty [points per sec]"
            text: qsTrId("props-detail-tg-penalty")
        }
        TextField{
            id: tg_penalty_textfield
        }

        NativeText {
            //% "Space gate max score [points]"
            text: qsTrId("props-detail-sg-max-score")
        }

        TextField{
            id: sg_max_score_textfield
        }

        NativeText {
            //% "Turn point max score [points]"
            text: qsTrId("props-detail-tp-max-score")
        }

        TextField{
            id: tp_max_score_textfield
        }

        NativeText {
            //% "Marker max score [points]"
            text: qsTrId("props-detail-marker-max-score")
        }
        TextField{
            id: marker_max_score_textfield
        }

        NativeText {
            //% "Photos max score [points]"
            text: qsTrId("props-detail-photos-max-score")
        }
        TextField{
            id: photos_max_score_textfield
        }

        NativeText {
            //% "Time window size [sec]"
            text: qsTrId("props-detail-time-window-size")
        }
        TextField{
            id: time_window_size_textfield
        }

        NativeText {
            //% "Time window penalty [%]"
            text: qsTrId("props-detail-time-window-penalty")
        }
        TextField{
            id: time_window_penalty_textfield
            text: ""
        }

        NativeText {
            //% "Altitude penalty [points per meter]"
            text: qsTrId("props-detail-alt-penalty")
        }
        TextField{
            id: alt_penalty_textfield
        }

        NativeText {
            //% "Gyre penalty [%]"
            text: qsTrId("props-detail-gyre-penalty")
        }
        TextField{
            id: gyre_penalty_textfield
            text: ""
        }

        NativeText {
            //% "Oposite direction penalty [%]"
            text: qsTrId("props-detail-oposite-direction-penalty")
        }
        TextField{
            id: oposite_direction_penalty_textfield
        }

        NativeText {
            //% "Out of sector pentaly [%]"
            text: qsTrId("props-detail-out-of-sector-penalty")
        }

        TextField{
            id: out_of_sector_penalty_textfield
        }

        NativeText {
            //% "Speed penalty [points per km/h]"
            text: qsTrId("props-detail-speed-penalty")
        }
        TextField{
            id: speed_penalty_textfield
        }

        NativeText {
            //% "Speed tolerance [km/h]"
            text: qsTrId("props-detail-speed-tolerance")
        }
        TextField{
            id: speed_tolerance_textfield
        }

        NativeText {
            //% "Preparation time [sec]"
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

        TextField{
            id: default_radius_textfield
        }


        NativeText {
            //% "Minimum Altitude [m]"
            text: qsTrId("props-detail-default_alt_min")
        }

        TextField{
            id: default_alt_min_textfield
        }

        NativeText {
            //% "Maximum Altitude [m]"
            text: qsTrId("props-detail-default_alt_max")
        }

        TextField{
            id: default_alt_max_textfield
        }


        //        NativeText {
        //            //% "Minimim Speed [km/h]"
        //            text: qsTrId("props-detail-default_speed_min")
        //        }

        //        TextField{
        //            id: default_speed_min_textfield
        //        }


        //        NativeText {
        //            //% "Maximum speed [km/h]"
        //            text: qsTrId("props-detail-default_speed_max")
        //        }

        //        TextField{
        //            id: default_speed_max_textfield
        //            text: default_speed_max
        //        }

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
        Item {
            visible: false;
            NativeText { text: " " }
            CheckBox {
                id: speed_min_cb;
                //% "Speed min"
                text: qsTrId("point-detail-speed-min-checkbox");
                onCheckedChanged: updateDefaultFlagsIndex(5, checked);
            }

            NativeText { text: " " }
            CheckBox {
                id: speed_max_cb;
                //% "Speed max"
                text: qsTrId("point-detail-speed-max-checkbox");
                onCheckedChanged: updateDefaultFlagsIndex(6, checked);
            }
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

