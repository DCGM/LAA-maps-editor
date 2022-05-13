import QtQuick 2.12
import QtQuick.Controls 2.12

Dialog {
    id: dialog;
    property alias question: questionText.text
    property alias text: textField.text;

    standardButtons: Dialog.Ok | Dialog.Cancel;
    contentItem: Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10;
        spacing: 15;

        NativeText {
            id: questionText
            width: parent.width;

        }

        TextField {
            id: textField;
            width: parent.width;
            onAccepted: {
                dialog.click(StandardButton.Ok);
            }
        }
    }

}
