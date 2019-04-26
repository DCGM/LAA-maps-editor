import QtQuick 2.9
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4

Dialog {
    id: dialog;
    property alias question: questionText.text
    property alias text: textField.text;

    standardButtons:  StandardButton.Ok;
    width: 500;
    height: 100;
    Column{
        anchors.fill: parent;
        spacing: 10;

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
