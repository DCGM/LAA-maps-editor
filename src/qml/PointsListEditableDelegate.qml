import QtQuick
import QtQuick.Controls
import "geom.js" as G
import "./components"



Item {
    id: editableDelegate
    signal changeModel(int row, string role, variant value);
    signal reverseGeocoding(int row);
    
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
        text: getStyledData(editableDelegate.value, editableDelegate.role) // zobrazi se ruzne podle role
        color: editableDelegate.textColor
        visible: !editableDelegate.selected
    }
    Loader { // Initialize text editor lazily to improve performance
        id: loaderEditor
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter


        anchors.margins: 4
        Connections {
            target: loaderEditor.item
//            function onAccepted() {
            onAccepted: {

                switch (editableDelegate.role) {
                case "name": // default
                    if (loaderEditor.item.text === "") {
                        reverseGeocoding(editableDelegate.row);
                        //% "Turn point"
                        changeModel(editableDelegate.row, editableDelegate.role, qsTrId("points-list-default-name"))
                    } else {
                        changeModel(editableDelegate.row, editableDelegate.role, loaderEditor.item.text)
                    }
                    break;
                case "pid":
                    console.log("Cannot change point id"); // neni mozne prepsat pid
                    break;
                case "lat":
                    changeModel(editableDelegate.row, editableDelegate.role, G.DMStoFloat(loaderEditor.item.text))
                    break;
                case "lon":
                    changeModel(editableDelegate.row, editableDelegate.role, G.DMStoFloat(loaderEditor.item.text))
                    break;
                default:
                    changeModel(editableDelegate.row, editableDelegate.role, loaderEditor.item.text)
                    break;
                }

            }
        }
        sourceComponent: editableDelegate.selected ? editor : null
        Component {
            id: editor
            TextInput {
                id: textinput

                color: editableDelegate.textColor
                text: getStyledData(editableDelegate.value, editableDelegate.role)

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
            return G.getLat(value,{coordinateFormat: "DMS"});
        case "lon":
            return G.getLon(value,{coordinateFormat: "DMS"});
        }

        return value;

    }
}

