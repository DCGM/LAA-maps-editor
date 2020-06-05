import QtQuick 2.9
import QtQuick.Controls 1.4


TextField {
    id: field

    property real value

    validator: DoubleValidator {
        bottom: 0
    }
    textColor: acceptableInput ? "#000000" : "#ff0000"

    onAccepted: {
        console.log(value)
    }

    onEditingFinished: {
        var numlocale = Qt.locale(locale);
        value = Number.fromLocaleString(numlocale, text)
    }

    onValueChanged: {
        var numlocale = Qt.locale(locale);
        var current = Number.fromLocaleString(numlocale, text)
        if (current !== value) {
            text = Number(value).toLocaleString(numlocale)
        }
    }
}
