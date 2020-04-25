import QtQuick 2.9
import QtQuick.Controls 1.4


ApplicationWindow {
    id: window

    //% "Line parameters"
    title: qsTrId("line-param-dialog-title")
    minimumHeight: grid.childrenRect.height + 2 * grid.anchors.margins + buttonRow.childrenRect.height + 2* buttonRow.padding
    minimumWidth: grid.childrenRect.width + 2 * grid.anchors.margins

    signal accepted();
    signal canceled();

    property alias distance: distance_textfield.text
    property alias angle: angle_textfield.text
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
            //% "Distance of next point (m)"
            text: qsTrId("line-param-dialog-distance")
        }
        TextField {
            id: distance_textfield
            text: "1000"
        }

        NativeText {
            //% "Angle (deg)"
            text: qsTrId("line-param-dialog-angle")
        }
        TextField {
            id: angle_textfield
            text: "90" // 3 nautical miles == 5556 (standard ATZ size)
        }



        NativeText {
            //% "Number of points"
            text: qsTrId("line-param-dialog-points")
        }
        TextField {
            id: points_number_textfield
            text: "10"
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
