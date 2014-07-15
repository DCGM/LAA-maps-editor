import QtQuick 2.2
import QtQuick.Controls 1.2
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
        visible: (styleData.role !== "pid") && (styleData.role !== "type")
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

        sourceComponent: (styleData.role === "cid") ? polygonSelection : null
        Component {
            id: polygonSelection
            ComboBox {
                id: combo
                width: 130;
                textRole: "name"
                property string tableCid: parseInt(styleData.value);

                signal newCid(int cid);
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

    }



}

