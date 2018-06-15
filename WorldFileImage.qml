import QtQuick 2.5
import "functions.js" as F

Item {
    id: worldFileImage;

    property variant param
    property double zone
    property bool northHemi



    property variant ut;
    property variant uts;
    property variant t: (ut !== undefined) ? getMappointFromCoord(ut[0], ut[1]) : [0, 0]
    property variant ts: (uts !== undefined) ? getMappointFromCoord(uts[0], uts[1]) : [0,0]

    x: (t !== undefined) ? (map.x + t[0]) : 0
    y: (t !== undefined) ? map.y + t[1] : 0
    width: (t !== undefined) ?  (Math.abs(ts[0] - t[0])) : 0
    height: (t !== undefined) ? (Math.abs(ts[1] - t[1])) : 0

    property alias source: inputImage.source

    Image {
        id: inputImage;
        anchors.fill: parent;
        onSourceSizeChanged: {
            worldFileImage.computeCoords( sourceSize.width, sourceSize.height)
//            console.log("image size: " + sourceSize.width + " " + sourceSize.height)
        }
    }

    //    Item {
    //        id: outputObject
    //        x: worldFileImage.x
    //        y: worldFileImage.y
    //        width: worldFileImage.width
    //        height: worldFileImage.height
    //    }

    function computeCoords(ssWidth, ssHeight) {

        var utmX1 = param[4] - (0.5 * param[0]);
        var utmY1 = param[5] - (0.5 * param[3]);
        var utmX2 = utmX1 + (ssWidth * param[0]);
//        var utmY2 = utmY1 + (ssHeight * param[3]);
        var utmY2 = utmY1 + ((ssHeight) * param[3]);
//        var utmY2 = utmY1 + (ssHeight * param[3]);

//        console.log("utmcoords: " + utmX1 + " " + utmX2 + " " + utmY1 + " " + utmY2)
//        console.log(param + " " +ssWidth + " " + ssHeight);

        var ll1 = F.rad2degPair( F.utmXYToLatLon(utmX1, utmY1, zone, !northHemi) );
        var ll2 = F.rad2degPair( F.utmXYToLatLon(utmX2, utmY1, zone, !northHemi) );
        var ll3 = F.rad2degPair( F.utmXYToLatLon(utmX1, utmY2, zone, !northHemi) );
        var ll4 = F.rad2degPair( F.utmXYToLatLon(utmX2, utmY2, zone, !northHemi) );


        ut  = [ Math.max(ll1[0], ll2[0], ll3[0], ll4[0]), Math.min(ll1[1], ll2[1], ll3[1], ll4[1]) ]
        uts = [ Math.min(ll1[0], ll2[0], ll3[0], ll4[0]), Math.max(ll1[1], ll2[1], ll3[1], ll4[1]) ]

//        console.log("ut: "+  ut)
//        console.log("uts: "+  uts)
//        console.log(ll1)
//        console.log(ll2)
//        console.log(ll3)
//        console.log(ll4)

        var sx = 1.0/(ut[0] - uts[0]);
        var sy = 1.0/(uts[1] - ut[1]);


        var a = Qt.point( sy*(ll1[1] - ut[1]), 1.0 - sx*(ll1[0] - uts[0]) )
        var c = Qt.point( sy*(ll2[1] - ut[1]), 1.0 - sx*(ll2[0] - uts[0]) )
        var b = Qt.point( sy*(ll3[1] - ut[1]), 1.0 - sx*(ll3[0] - uts[0]) )
        var d = Qt.point( sy*(ll4[1] - ut[1]), 1.0 - sx*(ll4[0] - uts[0]) )

        shader.a = a;
        shader.b = b;
        shader.c = c;
        shader.d = d;

//        console.log("shader input: " + a + " " +  b + " " + c + " " + d)


        wfcoords = [ll1, ll2, ll3, ll4]

        //        var Xh = 0.5*(utmX1+utmX2)
        //        var Yh = 0.5*(utmY1+utmY2)

        //        var ll7 = F.rad2degPair( F.UTMXYToLatLon(Xh, utmY2, wfZone, !wfNorthHemi) );
        //        var ll5 = F.rad2degPair( F.UTMXYToLatLon(Xh, utmY1, wfZone, !wfNorthHemi) );
        //        var ll6 = F.rad2degPair( F.UTMXYToLatLon(utmX1, Yh, wfZone, !wfNorthHemi) );
        //        var ll8 = F.rad2degPair( F.UTMXYToLatLon(Xh, Yh, wfZone, !wfNorthHemi) );
        //        var ll9 = F.rad2degPair( F.UTMXYToLatLon(utmX2, Yh, wfZone, !wfNorthHemi) );

        //        wfcoords = [ll1, ll5, ll2, ll9, ll8, ll6, ll3, ll7, ll4, ]

        canvas.requestPaint();

    }


    ShaderEffect {
        id: shader;
        property variant source: ShaderEffectSource { sourceItem: inputImage; hideSource: true; }
        anchors.fill: parent;

        //property variant a: [[0, 0], [1, 0], [0, 1], [1, 1]]
        property variant a: Qt.point(0, 0.00622009);
        property variant b: Qt.point(0.0200996, 1);
        property variant c: Qt.point(0.980166, 0);
        property variant d: Qt.point(1, 0.986063);
//        property variant e: Qt.point(0.4, 0.3);

        property url fragmentShaderFilename: Qt.resolvedUrl("fragment.fsh");

        onFragmentShaderFilenameChanged: {
            console.log("loading fragment shader from: " + fragmentShaderFilename)
            fragmentShader = file_reader.read(fragmentShaderFilename)
        }

    }


}
