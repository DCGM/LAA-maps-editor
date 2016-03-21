import QtQuick 2.5
import QtQuick.Controls 1.4
import "functions.js" as F


Item {
    id: delegate;
    property variant comboModel
    property variant typeModel
    property variant category_defaults;
    signal changeModel(int row, string role, variant value);

    NativeText {
        width: parent.width
        anchors.margins: 4
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        elide: styleData.elideMode
        text: getTextForRole(styleData.row, styleData.role, styleData.value);
        color: (styleData.value == -1
                || (styleData.role === "addTime" && styleData.value === 0)
                ) ? "#aaa" : styleData.textColor
        visible: ((styleData.role === "tid") || (styleData.role === "flags") || styleData.role === "distance_sum" ) || (!styleData.selected && (styleData.role !== "type"))

    }


    Loader { // Initialize text editor lazily to improve performance
        id: pidComboLoader
        //            anchors.fill: parent
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        anchors.margins: 4
        Connections {
            target: pidComboLoader.item
            onNewPid: {
                changeModel(styleData.row, styleData.role, pid)

            }
        }

        sourceComponent: (styleData.role === "pid") ? pointSelection : null
        Component {
            id: pointSelection
            ComboBox {
                id: combo
                width: delegate.width-10;
                textRole: "text"

                property int tablePid: parseInt(styleData.value);

                signal newPid(int pid);
                onCurrentIndexChanged: {
                    if (comboModel === undefined) {
                        return;
                    }

                    var it = comboModel.get(currentIndex);
                    if (it.pid != styleData.value) { // jen kdyz se zmenilo
                        newPid(it.pid);
                    }

                }

                onTablePidChanged: {
                    if (tablePid < 0) {
                        return;
                    }

                    model = comboModel
                    var toIdx = 0;

                    for (var i = 0; i < model.count; i++) {
                        var it = model.get(i);
                        if (it.pid == styleData.value) {
                            toIdx = i;
                            break;
                        }
                    }
                    currentIndex = toIdx;
                }



            }
        }

    }


    /// Type combobox

    Loader { // Initialize text editor lazily to improve performance
        id: loaderType
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        anchors.margins: 4
        Connections {
            target: loaderType.item

            onNewType: {
                changeModel(styleData.row, styleData.role, t)
            }

        }

        sourceComponent: ((styleData.role === "type") && (styleData.row !== 0)) ? typeSelection : null
        Component {
            id: typeSelection
            ComboBox {
                id: typeCombo
                width: delegate.width-10
                textRole: "text"

                property string tableType: styleData.value;
                signal newType(string t);


                onCurrentIndexChanged: {
                    if (typeModel === undefined) {
                        return;
                    }
                    var it = typeModel.get(currentIndex)
                    if (it.typeId != styleData.value) { // jen kdyz se zmenilo
                        newType(it.typeId);
                    }
                }


                onTableTypeChanged: {
                    if (tableType =="") {
                        return;
                    }

                    model = typeModel;
                    var toIdx = 0;
                    for (var i = 0; i < model.count; i++) {
                        var it = model.get(i);
                        if (it.typeId == styleData.value) {
                            toIdx = i;
                            break;
                        }
                    }
                    currentIndex = toIdx
                }
            }
        }

    }


    /// Angle (spinbox)

    //    Loader {
    //        id: loaderSpinBox;
    //        anchors.left: parent.left
    //        anchors.verticalCenter: parent.verticalCenter
    //        anchors.margins: 4

    //        Connections {
    //            target:loaderSpinBox.item
    //            onNewAngle: {
    //                changeModel(styleData.row, styleData.role, angle)
    //            }
    //        }
    //        sourceComponent: ((styleData.role === "angle") && (styleData.selected)) ? spinbox : null;
    //        Component {
    //            id: spinbox;
    //            SpinBox {
    //                signal newAngle(int angle);
    //                id: spinboxInput
    //                minimumValue: -1;
    //                maximumValue: 360;
    //                stepSize: 10;
    //                value: getTextForRole(styleData.row, styleData.role, styleData.value);
    //                font.weight: (styleData.value === -1) ? Font.Light : Font.Normal

    //                onEditingFinished: {
    //                    newAngle(value)
    //                }

    //            }
    //        }
    //    }

    /// Type other (editbox)

    Loader { // Initialize text editor lazily to improve performance
        id: loaderEditor
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        anchors.margins: 4
        Connections {
            target: loaderEditor.item
            onNewValue: {

                switch (styleData.role) {
                case "angle": // default
                case "distance":
                case "radius":
                case "speed_min":
                case "speed_max":
                case "alt_min":
                case "alt_max":
                case "ptr":
                    var num = parseFloat(value);
                    if (isNaN(num)) {
                        changeModel(styleData.row, styleData.role, -1)
                    } else {
                        changeModel(styleData.row, styleData.role, num)
                    }
                    break;
                case "addTime":
                    var str = value;
                    var regexp = /^(\d+):(\d+):(\d+)$/;
                    var result = regexp.exec(str);
                    if (result) {
                        var num = parseInt(result[1], 10) * 3600 + parseInt(result[2], 10) * 60 + parseInt(result[3], 10);
                        changeModel(styleData.row, styleData.role, num)
                    } else {
                        var num = parseFloat(str);
                        if (isNaN(num)) {
                            changeModel(styleData.row, styleData.role, 0)
                        } else {
                            changeModel(styleData.row, styleData.role, num)
                        }
                    }

                    break;
                default:
                    changeModel(styleData.row, styleData.role, value)
                    break;
                }

            }
        }
        sourceComponent:
            (
                styleData.role !== "tid" &&
                styleData.role !== "type" &&
                styleData.role !== "pid" &&
                styleData.role !== "flags" &&
                styleData.role !== "distance_sum"
             ) && (styleData.selected)
            ? editor : null

        Component {
            id: editor

            NativeTextInput {
                id: textinput
                signal newValue(string value);

                color: styleData.textColor
                text: getTextForRole(styleData.row, styleData.role, styleData.value);

                Keys.onUpPressed: {
                    if (styleData.role === "angle") {
                        text =parseInt(text) +10
                    }
                }

                Keys.onDownPressed: {
                    if (styleData.role === "angle") {
                        text = parseInt(text) - 10
                    }
                }

                onAccepted: {
                    newValue(text);
                }

                // Cannot use that. Some destructor is called before. Causing SIGSEGV
//                onEditingFinished: {
//                    newValue(text)
//                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: textinput.forceActiveFocus()
                    onWheel: {
                        if (wheel.angleDelta.y > 0) {
                            text = parseInt(text) + 10;
                        } else {
                            text = parseInt(text) - 10;
                        }
                    }
                }
            }
        }
    }



    function getTextForRole(row, role, value) {
        if (row < 0) {
            return "";
        }

        var show = value;

        // set up details
        if (value < 0) {
            switch (role) {
            case "flags":
                show = category_defaults.default_flags;
                break;
            case "angle":
                var it = tracksModel.get(styleData.row);
                show = Math.round(it.computed_angle)
                break;
            case "distance":
                var it = tracksModel.get(styleData.row);
                show = Math.round(it.computed_distance)
                break;
            case "radius":
                show = category_defaults.default_radius;
                break;
            case "speed_min":
                show = category_defaults.default_speed_min;
                break;
            case "speed_max":
                show = category_defaults.default_speed_max;
                break;
            case "alt_min":
                show = category_defaults.default_alt_min;
                break;
            case "alt_max":
                show = category_defaults.default_alt_max;
                break;
            default:
                show = value;
                break;
            }
        }

        switch (role) {
        case "flags":
            show = flagsToStr(show);
            break;
        case "addTime":
            show = F.addTimeStrFormat(value)
            break;
        case "distance_sum":
            var distance_sum = 0;
            for (var i = 0; ((i < tracksModel.count) && (i <= styleData.row)); i++) {
                var item = tracksModel.get(i);
                var distance = (item.distance !== -1) ? item.distance : item.computed_distance
                distance_sum += distance;
                show = Math.round(distance_sum);
            }

            break;

        default:

        }


        return show;
    }


    function flagsToStr(f) {
        var arr = F.arrayFromMask(f  | 0x10000);

        if (arr.length === 0) {
            return "";
        }
        var strings = [];

        if (arr[0]) {
            //% "TP"
            strings.push(qsTrId("track-list-delegate-ob-short"))
        }
        if (arr[1]) {
            //% "TG"
            strings.push(qsTrId("track-list-delegate-tg-short"))
        }
        if (arr[2]) {
            //% "SG"
            strings.push(qsTrId("track-list-delegate-sg-short"))
        }

        if (arr[3]){
            //% "ALT_MIN"
            strings.push(qsTrId("track-list-delegate-alt_min-short"))
        }
        if (arr[4]) {
            //% "ALT_MAX"
            strings.push(qsTrId("track-list-delegate-alt_max-short"))
        }
        if (arr[5]) {
            //% "SPD_MIN"
            strings.push(qsTrId("track-list-delegate-speed_min-short"))
        }
        if (arr[6]) {
            //% "SPD_MAX"
            strings.push(qsTrId("track-list-delegate-speed_max-short"))
        }

        if (arr[7]) {
            //% "sss"
            strings.push(qsTrId("track-list-delegate-section_speed_start-short"))
        }
        if (arr[8]) {
            //% "sse"
            strings.push(qsTrId("track-list-delegate-section_speed_end-short"))
        }
        if (arr[9]) {
            //% "sas"
            strings.push(qsTrId("track-list-delegate-section_alt_start-short"))
        }
        if (arr[10]) {
            //% "sae"
            strings.push(qsTrId("track-list-delegate-section_alt_end-short"))
        }

        if (arr[11]) {
            //% "sws"
            strings.push(qsTrId("track-list-delegate-section_space_start-short"))
        }

        if (arr[12]) {
            //% "swe"
            strings.push(qsTrId("track-list-delegate-section_space_end-short"))
        }


        if (arr[13]) {
            //% "sec_tp"
            strings.push(qsTrId("track-list-delegate-secret-turn-point-short"))
        }

        if (arr[14]) {
            //% "sec_tg"
            strings.push(qsTrId("track-list-delegate-secret-time-gate-short"))
        }

        if (arr[15]) {
            //% "sec_sg"
            strings.push(qsTrId("track-list-delegate-secret-space-gate-short"))
        }




        return strings.join(", ");
    }


}

