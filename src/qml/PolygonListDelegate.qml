import QtQuick
import QtQuick.Controls
import "functions.js" as F
import "./components"


Item {
    id: editableDelegate
    signal changeModel(int row, string role, string value);
    signal openColorDialog(int row, string prevValue);

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
        elide: editableDelegate.elideMode
        text: editableDelegate.value
        color: editableDelegate.textColor
        visible: !editableDelegate.selected && (editableDelegate.role !== "closed") && (editableDelegate.role !== "color")
    }
    Loader { // Initialize text editor lazily to improve performance
        id: loaderEditor
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        anchors.margins: 4
        Connections {
            target: loaderEditor.item
            onAccepted: {
//            function onAccepted() {

                switch (editableDelegate.role) {
                case "name": // default
                    if (loaderEditor.item.text === "") {
                        //% "Polygon"
                        changeModel(editableDelegate.row, editableDelegate.role, qsTrId("polygon-list-default-name"));
                    } else {
                        changeModel(editableDelegate.row, editableDelegate.role, loaderEditor.item.text)
                    }
                    break;
                case "color": // default
                    changeModel(editableDelegate.row, editableDelegate.role, validateColor(loaderEditor.item.text))
                    break;
                case "cid":
                    console.log("Cannot change point id"); // neni mozne prepsat pid
                    break;
                case "point_count":
                    console.log("Cannot change point count so easy"); // neni mozne prepsat pocet bodu (TODO: editor bodu)
                    break;
                case "closed":
                    changeModel(editableDelegate.row, editableDelegate.role, loaderEditor.item.checked)
                    break;
                default:
                    changeModel(editableDelegate.row, editableDelegate.role, loaderEditor.item.text)
                    break;
                }

            }
        }
        sourceComponent: (editableDelegate.role === "closed") ? btn : ( (editableDelegate.role === "color") ? colorRect : (editableDelegate.selected ? editor : null) )
        Component {
            id: btn
            CheckBox {
                checked: editableDelegate.value;
                signal accepted();
                onClicked: {
                    accepted();
                }
            }
        }
        Component {
            id: colorRect
            Rectangle {
                width: 10;
                height: 10;
                color: "#" + editableDelegate.value
                signal accepted();
                MouseArea {
                    anchors.fill: parent;
                    onClicked: {
                        openColorDialog(editableDelegate.row, editableDelegate.value)
                    }
                }
            }
        }

        Component {
            id: editor
            TextInput {
                id: textinput

                color: editableDelegate.textColor
                text: editableDelegate.value

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        textinput.forceActiveFocus()
                        if (editableDelegate.role === "color") {
                            openColorDialog(editableDelegate.row, editableDelegate.value)
                        }
                    }
                }
            }
        }
    }

    function validateColor(colorStr) {
        var reg_exp = /^([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3}|[A-Fa-f0-9]{8})$/i;
        var match = reg_exp.exec(colorStr);

        if (match === null) {
            return "FF0000FF"; // default color
        }
        return String(colorStr).toUpperCase()

    }


}
