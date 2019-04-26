import QtQuick 2.9
import QtQuick.Controls 1.4
import "functions.js" as F


Item {
    id: item;
    property variant comboModel
    property variant typeModel
    signal changeModel(int row, string role, variant value);


    NativeText {
        width: parent.width
        anchors.margins: 4
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        elide: styleData.elideMode
        text: styleData.value;
        color: styleData.textColor
        visible: (styleData.role === "did") || ((styleData.role === "score") && !styleData.selected)
    }

    Loader { // Initialize text editor lazily to improve performance
        id: cidComboLoader
        //            anchors.fill: parent
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        anchors.margins: 4
        Connections {
            target: cidComboLoader.item
            onNewCid: {
                changeModel(styleData.row, styleData.role, cid)
            }
        }

        Connections {
            target: cidComboLoader.item
            onNewScore: {
                changeModel(styleData.row, styleData.role, value)
            }
        }

        sourceComponent: (styleData.role === "cid") ? polygonSelection : ((styleData.selected && styleData.role === "score") ? polygonScoreText : null)
        Component {
            id: polygonSelection
            ComboBox {
                id: combo
                width: 130;
                textRole: "name"
                property string tableCid: parseInt(styleData.value);

                signal newCid(int cid);
                signal newScore(int value);

                onCurrentIndexChanged: {
                    if (comboModel === undefined) {
                        return;
                    }

                    var it = comboModel.get(currentIndex);
                    if (it.cid != styleData.value) {
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
                        if (it.cid == styleData.value) {
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
            NativeTextInput {
                id: textinput

                signal newCid();
                signal newScore(int value);
                color: styleData.textColor
                text: styleData.value
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

