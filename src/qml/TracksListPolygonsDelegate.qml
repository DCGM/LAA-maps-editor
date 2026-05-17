import QtQuick
import QtQuick.Controls
import "functions.js" as F
import "./components"


Item {
    id: item;
    height: parent ? parent.height : 30
    property variant comboModel
    property variant typeModel
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
        elide: item.elideMode
        text: item.value;
        color: item.textColor
        visible: (item.role === "did") || ((item.role === "score") && !item.selected)
    }

    Loader { // Initialize text editor lazily to improve performance
        id: cidComboLoader
        //            anchors.fill: parent
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        anchors.margins: 4
        Connections {
            target: cidComboLoader.item
            function onNewCid(cid) {
                changeModel(item.row, item.role, cid)
            }
        }

        Connections {
            target: cidComboLoader.item
            function onNewScore(value) {
                changeModel(item.row, item.role, value)
            }
        }

        sourceComponent: (item.role === "cid") ? polygonSelection : ((item.selected && item.role === "score") ? polygonScoreText : null)
        Component {
            id: polygonSelection
            ComboBox {
                id: combo
                width: 130;
                textRole: "name"
                property string tableCid: parseInt(item.value);

                signal newCid(int cid);
                signal newScore(int value);

                onCurrentIndexChanged: {
                    if (comboModel === undefined) {
                        return;
                    }

                    var it = comboModel.get(currentIndex);
                    if (it.cid != item.value) {
                        newCid(it.cid);
                    }
                }

                onTableCidChanged: {
                    if (isNaN(tableCid)) {
                        return;
                    }

                    if (tableCid < 0) {
                        return;
                    }

                    model = comboModel
                    var toIdx = 0;

                    for (var i = 0; i < model.count; i++) {
                        var it = model.get(i);
                        if (it.cid == item.value) {
                            toIdx = i;
                            break;
                        }
                    }


                    currentIndex = toIdx;

                }
            }
        }

        Component {
            id: polygonScoreText
            TextInput {
                id: textinput

                signal newCid();
                signal newScore(int value);
                color: item.textColor
                text: item.value
                onAccepted: {
                    newScore(parseInt(textinput.text, 10))
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: textinput.forceActiveFocus();
                }
            }

        }
    }



}

