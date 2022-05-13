import QtQuick 2.12
import QtQuick.Controls 2.12
import "./components"


ApplicationWindow {
    id: window

    //% "Circle parameters"
    title: qsTrId("circle-param-dialog-title")
    minimumHeight: grid.childrenRect.height + 2 * grid.anchors.margins + buttonRow.childrenRect.height + 2* buttonRow.padding
    minimumWidth: grid.childrenRect.width + 2 * grid.anchors.margins
    modality: Qt.ApplicationModal

    signal accepted();
    signal canceled();

    property alias radius: radius_textfield.text
    property alias points: points_number_textfield.text

    Grid {
        id: grid
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: parent.top;
        anchors.bottom: buttonRow.top;

        anchors.margins: 10;
        spacing: 5
        columns: 2;

        NativeText {
            //% "Radius (m)"
            text: qsTrId("circle-param-dialog-radius")
        }
        TextField {
            id: radius_textfield
            text: "5556" // 3 nautical miles == 5556 (standard ATZ size)
        }

        NativeText {
            //% "Number of points"
            text: qsTrId("circle-param-dialog-points")
        }
        TextField {
            id: points_number_textfield
            text: "25"
        }

    }

    Row {
        id: buttonRow

        anchors.bottom: parent.bottom;
        anchors.right: parent.right;
        anchors.margins: 10;
        spacing: 5;

        Button {
            //% "Ok"
            text: qsTrId("track-statistics-ok")
            onClicked: {
                window.visible = false;
                accepted();
            }
        }
        Button {
            //% "Cancel"
            text: qsTrId("track-statistics-cancel")
            onClicked: {
                window.visible = false;
                canceled();
            }
        }
    }

}
