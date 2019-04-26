import QtQuick 2.9
import "functions.js" as F

Item {
    id: ruler

    x: x1;
    y: y1;
    width: hypotenuse
    height: 3;
    visible: false;

    transform: Rotation { origin.x: 0; origin.y: 0; angle: ruler.computed_angle}

    property alias distance: distance_text.text

    property real mapx;
    property real mapy;

    property variant startPoint
    property variant endPoint


    property real x1: mapx + startPoint[0];
    property real y1: mapy + startPoint[1];
    property real x2: mapx + endPoint[0];
    property real y2: mapy + endPoint[1];

    property real computed_angle: F.rad2deg(Math.atan2(y2-y1, x2-x1));
    property real hypotenuse: F.euclidDistance(x1, y1, x2, y2);

    Rectangle {
        anchors.fill: parent;
        color: "#000066"
        opacity: 0.6
        smooth: true;
    }

    NativeText {
        id: distance_text
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.top
        smooth: true;
        font.weight: Font.DemiBold
        renderType: ruler.computed_angle != 0 ? Text.QtRendering : Text.NativeRendering

    }

}
