import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import "functions.js" as F

ApplicationWindow {
    id: dialog;
    width: 640
    height: 300

    property alias wffiles: files
    signal accepted(variant list);
    signal canceled();

    ListModel {
        id: files;
    }


    //    FileDialog {
    //        id: gfwFileDialog;
    //        nameFilters: [
    //            //% "ESRI World file"
    //            qsTrId("gfw-dialog-browse-gfw-gfw")+" (*.gfw *.jgw *.tfw)",
    //            //% "All files"
    //            qsTrId("gfw-dialog-browse-gfw-all-files")+" (*)"
    //        ]
    //        onAccepted: {
    //            gfwTextField.text = fileUrl;
    //        }
    //    }

    FileDialog {
        id: imageFileDialog;
        nameFilters: [
            //% "Images"
            qsTrId("gfw-dialog-browse-image-images")+"(*.jpg *.png *.gif)",
            //% "All files"
            qsTrId("gfw-dialog-browse-image-all-files")+" (*)"
        ]
        selectMultiple: true;
        selectExisting: true;
        selectFolder: false;
        onAccepted: {
            for (var i = 0; i < fileUrls.length; ++i) {
                var fn = fileUrls[i];
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
                    //                    break;
                }

                files.append({"image": fn, "gfw": fw})

                //                console.log("pair " + fn + " " + fw)


            }

        }

    }




    TableView {
        id: selectedFilesTable;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: parent.top;
        anchors.margins: 10;
        selectionMode: SelectionMode.ExtendedSelection;

        model:  files;
        TableViewColumn {
            title: "image"
            role: "image"
            width: selectedFilesTable.width/2
        }
        TableViewColumn {
            title: "gfw"
            role: "gfw"
            width: selectedFilesTable.width/2
        }
    }

    Row {
        id: tableButtonsRow;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: selectedFilesTable.bottom;
        anchors.margins: 10;
        spacing: 10;

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
                selectedFilesTable.selection.forEach( function(rowIndex) {
                    files.remove(rowIndex-removedCount, 1);
                    removedCount++;
                })
                selectedFilesTable.selection.deselect(0, files.count-1)
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


    Grid {
        id: gfwRow
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: tableButtonsRow.bottom;
        anchors.margins: 10;
        spacing: 10;
        columns: 2



        ///

        NativeText {
            //% "UTM Zone"
            text: qsTrId("gfw-dialog-utm-zone");
        }

        TextField {
            id: utmZoneTextField
            text: "33"
        }


        NativeText {
            //% "North hemisphere"
            text: qsTrId("gfw-dialog-north-hemisphere")
        }

        CheckBox {
            id: hemisphereCheckbox
            checked: true;

        }


    }


    Row {
        id: dialogButtons
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10;
        spacing: 10;
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
