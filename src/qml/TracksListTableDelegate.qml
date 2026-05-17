import QtQuick
import QtQuick.Controls
import "functions.js" as F
import "./components"


Item {
    id: delegate;
    height: parent ? parent.height : 30
    property variant comboModel
    property variant typeModel
    property variant category_defaults;
    signal changeModel(int row, string role, variant value);

    property int row
    property string role
    property variant value
    property bool selected: false
    property color textColor: selected ? "white" : "black"
    property int elideMode: Text.ElideRight

    Text {
        width: parent.width
        anchors.margins: 4
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        elide: delegate.elideMode
        text: getTextForRole(delegate.row, delegate.role, delegate.value);
        color: (delegate.value === -1
                || (delegate.role === "addTime" && delegate.value === 0)
                ) ? "#aaa" : delegate.textColor
        visible: ((delegate.role === "tid") || (delegate.role === "flags") || delegate.role === "distance_sum" ) || (!delegate.selected && (delegate.role !== "type"))

    }


    Loader { // Initialize text editor lazily to improve performance
        id: pidComboLoader
        //            anchors.fill: parent
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        anchors.margins: 4
        Connections {
            target: pidComboLoader.item
            function onNewPid(pid) {
                changeModel(delegate.row, delegate.role, pid)
            }
        }

        sourceComponent: (delegate.role === "pid") ? pointSelection : null
        Component {
            id: pointSelection
            ComboBox {
                id: combo
                width: delegate.width - 10
                textRole: "text"
                model: comboModel

                property int tablePid: parseInt(delegate.value)
                property bool initializing: true
                signal newPid(int pid)

                function updateIndex() {
                    if (!model || model.count === 0) return;
                    initializing = true;
                    var target = delegate.value;
                    for (var i = 0; i < model.count; i++) {
                        var it = model.get(i);
                        if (it.pid == target) {  // == for type-safe comparison
                            currentIndex = i;
                            initializing = false;
                            return;
                        }
                    }
                    currentIndex = 0;
                    initializing = false;
                }

                Component.onCompleted: updateIndex()
                onModelChanged: if (model && model.count > 0) updateIndex()
                onTablePidChanged: if (model && model.count > 0) updateIndex()

                onCurrentIndexChanged: {
                    if (initializing || !model || model.count === 0 || currentIndex < 0) return;
                    var it = model.get(currentIndex);
                    if (it && it.pid != delegate.value) {
                        newPid(it.pid);
                    }
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
            function onNewType(t) {
                changeModel(delegate.row, delegate.role, t)
            }
        }

        sourceComponent: ((delegate.role === "type") && (delegate.row !== 0)) ? typeSelection : null
        Component {
            id: typeSelection
            ComboBox {
                id: typeCombo
                width: delegate.width - 10
                textRole: "text"
                model: typeModel

                property string tableType: (delegate.value !== undefined && delegate.value !== null) ? delegate.value : ""
                property bool initializing: true
                signal newType(string t)

                function updateIndex() {
                    if (!model || model.count === 0 || tableType === "") return;
                    initializing = true;
                    var target = delegate.value;
                    for (var i = 0; i < model.count; i++) {
                        var it = model.get(i);
                        if (it.typeId === target) {
                            currentIndex = i;
                            initializing = false;
                            return;
                        }
                    }
                    initializing = false;
                }

                Component.onCompleted: updateIndex()
                onModelChanged: if (model && model.count > 0) updateIndex()
                onTableTypeChanged: if (model && model.count > 0) updateIndex()

                onCurrentIndexChanged: {
                    if (initializing || !model || model.count === 0 || currentIndex < 0) return;
                    var it = model.get(currentIndex);
                    if (it && it.typeId !== delegate.value) {
                        newType(it.typeId);
                    }
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
    ////                function onNewAngle(angle) {
    //                changeModel(delegate.row, delegate.role, angle)
    //            }
    //        }
    //        sourceComponent: ((delegate.role === "angle") && (delegate.selected)) ? spinbox : null;
    //        Component {
    //            id: spinbox;
    //            SpinBox {
    //                signal newAngle(int angle);
    //                id: spinboxInput
    //                minimumValue: -1;
    //                maximumValue: 360;
    //                stepSize: 10;
    //                value: getTextForRole(delegate.row, delegate.role, delegate.value);
    //                font.weight: (delegate.value === -1) ? Font.Light : Font.Normal

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
            function onNewValue(value) {
                switch (delegate.role) {
                case "angle": // default
                    var num = parseFloat(value);
                    if (isNaN(num)) {
                        changeModel(delegate.row, delegate.role, -1)
                    } else {
                        num = (num + 90) % 360
                        changeModel(delegate.row, delegate.role, num)
                    }
                    break;
                case "distance":
                case "radius":
                case "alt_min":
                case "alt_max":
                case "ptr":
                    var num = parseFloat(value);
                    if (isNaN(num)) {
                        changeModel(delegate.row, delegate.role, -1)
                    } else {
                        changeModel(delegate.row, delegate.role, num)
                    }
                    break;
                case "addTime":
                    var str = value;
                    var regexp = /^(\d+):(\d+):(\d+)$/;
                    var result = regexp.exec(str);
                    if (result) {
                        var num = parseInt(result[1], 10) * 3600 + parseInt(result[2], 10) * 60 + parseInt(result[3], 10);
                        changeModel(delegate.row, delegate.role, num)
                    } else {
                        var num = parseFloat(str);
                        if (isNaN(num)) {
                            changeModel(delegate.row, delegate.role, 0)
                        } else {
                            changeModel(delegate.row, delegate.role, num)
                        }
                    }

                    break;
                default:
                    changeModel(delegate.row, delegate.role, value)
                    break;
                }

            }
        }
        sourceComponent:
            (
                delegate.role !== "tid" &&
                delegate.role !== "type" &&
                delegate.role !== "pid" &&
                delegate.role !== "flags" &&
                delegate.role !== "distance_sum"
             ) && (delegate.selected)
            ? editor : null

        Component {
            id: editor

            TextInput {
                id: textinput
                signal newValue(string value);

                color: delegate.textColor
                text: getTextForRole(delegate.row, delegate.role, delegate.value);

                Keys.onUpPressed: {
                    if (delegate.role === "angle") {
                        text =parseInt(text) +10
                    }
                }

                Keys.onDownPressed: {
                    if (delegate.role === "angle") {
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
                var it = tracksModel.get(delegate.row);
                show = Math.round(it.computed_angle)
                break;
            case "distance":
                var it = tracksModel.get(delegate.row);
                show = Math.round(it.computed_distance)
                break;
            case "radius":
                show = category_defaults.default_radius;
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
        case "angle": // adjust angle by 90 deg
            show = (show + 270) % 360;
            break;
        case "flags":
            show = flagsToStr(show);
            break;
        case "addTime":
            show = F.addTimeStrFormat(value)
            break;
        case "distance_sum":
            var distance_sum = 0;
            for (var i = 0; ((i < tracksModel.count) && (i <= delegate.row)); i++) {
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

