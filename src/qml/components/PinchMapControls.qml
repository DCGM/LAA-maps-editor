import QtQuick 2.0
import QtQuick.Layouts 1.3


ColumnLayout {

    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.rightMargin: 16
    anchors.bottomMargin: 16
    spacing: 0

    signal zoomIn()
    signal zoomOut()
    signal panToMyPosition();

    Item {
        width: 25
        height: 25
        visible: parent.visible

        ShadowElement { // just for effect
            anchors.fill: centerButton
            source: centerButton
        }

        Rectangle {
            id: centerButton
            anchors.fill: parent;
            radius: 3

            Image {
                source: "qrc:///images/ic_my_location_black_24dp_1x.png"
            }
            MouseArea {
                anchors.fill: parent;
                onClicked: panToMyPosition();
            }
        }
    }

    Rectangle { // spacer
        color: "transparent"
        height: 4
    }

    Item {
        width: 25
        height: 50

        ShadowElement { // just for effect
            anchors.fill: zoomButtons
            source: zoomButtons
        }

        Rectangle {
            id: zoomButtons
            anchors.fill: parent;
            radius: 3

            ColumnLayout {

                anchors.fill: parent
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true;
                    Layout.preferredHeight: parent.height/2;
                    radius: 3

                    Image {
                        id: add_img
                        source: "qrc:///images/ic_add_black_24dp_1x.png"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: zoomIn();
                    }
                }

                Rectangle {

                    height: 1
                    color: "#9F9F9F"
                    Layout.fillWidth: true;
                    Layout.margins: 2;
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter;

                }

                Rectangle {
                    Layout.fillWidth: true;
                    Layout.preferredHeight: parent.height/2;
                    radius: 3

                    Image {
                        source: "qrc:///images/ic_remove_black_24dp_1x.png"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: zoomOut();
                    }
                }
            }
        }
    }
}
