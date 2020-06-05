import QtQuick 2.9
import QtQuick.Controls 1.4


TextField {
    id: field

    property real value
    property alias validatorBottom: val.bottom

    validator: DoubleValidator {
        id: val;
        bottom: 0;
    }
    textColor: acceptableInput ? "#000000" : "#ff0000"

    onEditingFinished: {
        var numlocale = Qt.locale(locale);
        value = Number.fromLocaleString(numlocale, text)
    }

    onValueChanged: {
        var numlocale = Qt.locale(locale);
        var current = Number.fromLocaleString(numlocale, text)

        if (current !== value) { // use only when loading
            text = Number(value).toLocaleString(numlocale,'f', -128) // see QLocale::FloatingPointShortest
        }
    }

}
