import QtQuick 2.5
import QtQuick.Controls 1.4
import "functions.js" as F


Item {
    id: editableDelegate
    signal changeModel(int row, string role, string value);
    signal openColorDialog(int row, string prevValue);


    NativeText {
        width: parent.width
        anchors.margins: 4
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        elide: styleData.elideMode
        text: styleData.value
        color: styleData.textColor
        visible: !styleData.selected && (styleData.role !== "closed") && (styleData.role !== "color")
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

                switch (styleData.role) {
                case "name": // default
                    if (loaderEditor.item.text === "") {
                        //% "Polygon"
                        changeModel(styleData.row, styleData.role, qsTrId("polygon-list-default-name"));
                    } else {
                        changeModel(styleData.row, styleData.role, loaderEditor.item.text)
                    }
                    break;
                case "color": // default
                    changeModel(styleData.row, styleData.role, validateColor(loaderEditor.item.text))
                    break;
                case "cid":
                    console.log("Cannot change point id"); // neni mozne prepsat pid
                    break;
                case "point_count":
                    console.log("Cannot change point count so easy"); // neni mozne prepsat pocet bodu (TODO: editor bodu)
                    break;
                case "closed":
                    changeModel(styleData.row, styleData.role, loaderEditor.item.checked)
                    break;
                default:
                    changeModel(styleData.row, styleData.role, loaderEditor.item.text)
                    break;
                }

            }
        }
        sourceComponent: (styleData.role === "closed") ? btn : ( (styleData.role === "color") ? colorRect : (styleData.selected ? editor : null) )
        Component {
            id: btn
            CheckBox {
                checked: styleData.value;
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
                color: "#" + styleData.value
                signal accepted();
                MouseArea {
                    anchors.fill: parent;
                    onClicked: {
                        openColorDialog(styleData.row, styleData.value)
                    }
                }
            }
        }

        Component {
            id: editor
            NativeTextInput {
                id: textinput

                color: styleData.textColor
                text: styleData.value

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        textinput.forceActiveFocus()
                        if (styleData.role === "color") {
                            openColorDialog(styleData.row, styleData.value)
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
