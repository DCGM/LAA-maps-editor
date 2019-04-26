import QtQuick 2.9
import QtQuick.Controls 1.4
import "functions.js" as F



Item {
    id: editableDelegate
    signal changeModel(int row, string role, variant value);
    signal reverseGeocoding(int row);

    NativeText {
        width: parent.width
        anchors.margins: 4
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        elide: styleData.elideMode
        text: getStyledData(styleData.value, styleData.role) // zobrazi se ruzne podle role
        color: styleData.textColor
        visible: !styleData.selected
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
                        reverseGeocoding(styleData.row);
                        //% "Turn point"
                        changeModel(styleData.row, styleData.role, qsTrId("points-list-default-name"))
                    } else {
                        changeModel(styleData.row, styleData.role, loaderEditor.item.text)
                    }
                    break;
                case "pid":
                    console.log("Cannot change point id"); // neni mozne prepsat pid
                    break;
                case "lat":
                    changeModel(styleData.row, styleData.role, F.DMStoFloat(loaderEditor.item.text))
                    break;
                case "lon":
                    changeModel(styleData.row, styleData.role, F.DMStoFloat(loaderEditor.item.text))
                    break;
                default:
                    changeModel(styleData.row, styleData.role, loaderEditor.item.text)
                    break;
                }

            }
        }
        sourceComponent: styleData.selected ? editor : null
        Component {
            id: editor
            NativeTextInput {
                id: textinput

                color: styleData.textColor
                text: getStyledData(styleData.value, styleData.role)

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: textinput.forceActiveFocus();
                }
            }
        }
    }

    function getStyledData(value, role) {
        if (value === undefined)
            return "";

        switch (role) {
        case "lat":
            return F.getLat(value,{coordinateFormat: "DMS"});
        case "lon":
            return F.getLon(value,{coordinateFormat: "DMS"});
        }

        return value;

    }
}

