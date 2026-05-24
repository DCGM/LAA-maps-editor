import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform as Platform

ApplicationWindow {
    id: dialog;
    width: 640
    height: 450
    visible: false

    property alias wffiles: files
    signal accepted(variant list);
    signal canceled();

    ListModel {
        id: files;
    }

    QtObject {
        id: selectionData
        property var items: []
        property int count: items.length
        function clear() { items = []; itemsChanged(); }
        function select(idx) { 
            var newItems = items.slice();
            if (newItems.indexOf(idx) === -1) { 
                newItems.push(idx); 
                items = newItems; 
            } 
        }
        function deselect(start, end) { 
            var newItems = [];
            for (var i = 0; i < items.length; i++) {
                if (items[i] < start || items[i] > end) {
                    newItems.push(items[i]);
                }
            }
            items = newItems;
        }
        function forEach(cb) { items.forEach(cb); }
        function contains(idx) { return items.indexOf(idx) !== -1; }
        signal selectionChanged()
        onItemsChanged: selectionChanged()
    }

    Platform.FileDialog {
        id: imageFileDialog;
        fileMode: Platform.FileDialog.OpenFiles
        nameFilters: [
            //% "Images"
            qsTrId("gfw-dialog-browse-image-images")+"(*.jpg *.png *.gif)",
            //% "All files"
            qsTrId("gfw-dialog-browse-image-all-files")+" (*)"
        ]
        onAccepted: {
            for (var i = 0; i < files.length; ++i) {
                var fn = files[i];
                var ext_regexp = /\.[^/.]+$/;
                var match = String(fn).match(ext_regexp);
                var fw = fn.replace(ext_regexp, "")

                switch (String(match)) {
                case ".gif":
                    fw += ".gfw";
                    break;
                case ".jpg":
                    fw += ".jfw";
                    break;
                case ".tif":
                    fw += ".tfw";
                    break;
                default:
                    console.log("unknown type \""+match+"\" filename \"" +fn + "\"");
                    continue;
                }
                var file = {"image": fn, "gfw": fw}
                files.append(file)
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            height: 30
            color: "#eee"
            RowLayout {
                anchors.fill: parent
                Text { text: "image"; Layout.preferredWidth: dialog.width/2 - 10 }
                Text { text: "gfw"; Layout.fillWidth: true }
            }
        }

        ListView {
            id: selectedFilesTable
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: files
            clip: true

            delegate: Rectangle {
                width: selectedFilesTable.width
                height: 30
                color: selectionData.contains(index) ? "#0077cc" : (index % 2 == 0 ? "#fff" : "#eee")

                MouseArea {
                    anchors.fill: parent
                    onClicked: (mouse) => {
                        if (mouse.modifiers & Qt.ControlModifier) {
                            if (selectionData.contains(index)) {
                                var newItems = selectionData.items.filter(i => i !== index);
                                selectionData.items = newItems;
                            } else {
                                selectionData.select(index);
                            }
                        } else {
                            selectionData.clear();
                            selectionData.select(index);
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    Text { text: model.image; color: selectionData.contains(index) ? "white" : "black"; Layout.preferredWidth: dialog.width/2 - 10; elide: Text.ElideRight }
                    Text { text: model.gfw; color: selectionData.contains(index) ? "white" : "black"; Layout.fillWidth: true; elide: Text.ElideRight }
                }
            }
        }

        RowLayout {
            id: tableButtonsRow
            Layout.fillWidth: true
            spacing: 10

            Button {
                //% "Add"
                text: qsTrId("gfw-dialog-add")
                onClicked: {
                    imageFileDialog.open()
                }
            }

            Button {
                //% "Remove selected"
                text: qsTrId("gfw-dialog-remove-selected")
                onClicked: {
                    var removedCount = 0;
                    selectionData.forEach( function(rowIndex) {
                        files.remove(rowIndex-removedCount, 1);
                        removedCount++;
                    })
                    selectionData.clear()
                }
            }

            Button {
                //% "Remove all"
                text: qsTrId("gfw-dialog-remove-all")
                onClicked: {
                    files.clear();
                }
            }
        }

        GridLayout {
            id: gfwRow
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 10
            columnSpacing: 10

            Text {
                //% "UTM Zone"
                text: qsTrId("gfw-dialog-utm-zone");
            }

            TextField {
                id: utmZoneTextField
                text: "33"
            }

            Text {
                //% "North hemisphere"
                text: qsTrId("gfw-dialog-north-hemisphere")
            }

            CheckBox {
                id: hemisphereCheckbox
                checked: true;
            }
        }

        RowLayout {
            id: dialogButtons
            Layout.alignment: Qt.AlignRight
            spacing: 10
            Button {
                //% "&Accept"
                text: qsTrId("gfw-dialog-accept")
                onClicked: {
                    var filesCopy = [];
                    for (var i = 0; i < files.count; i++) {
                        var item = files.get(i);
                        filesCopy.push({"image": item.image, "gfw": item.gfw, "utmZone": parseFloat(utmZoneTextField.text), "northHemisphere": hemisphereCheckbox.checked});
                    }
                    accepted(filesCopy);
                    dialog.close();
                }
            }
            Button {
                //% "&Cancel"
                text: qsTrId("gfw-dialog-cancel")
                onClicked: {
                    canceled();
                    dialog.close();
                }
            }
        }
    }
}
