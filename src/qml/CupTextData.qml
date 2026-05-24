import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: tabView

    property variant tracksData;

    signal pointsUpdated(variant p);
    signal pointSnap(int pid)
    signal polygonsUpdated(variant p);
    signal tracksUpdated(variant t);
    signal pointListItemSelected(int pid);
    signal trackListItemSelected(int tid);
    signal polyListItemSelected(int cid);

    property int selectedCategoryIndex: 0
    property alias currentIndex: tabBar.currentIndex

    property int pointPidSelectedFromMap;
    property variant newPointPosition;
    property variant computedData;

    property real mapCenterLat
    property real mapCenterLon
    property bool showTrackAlways;

    TabBar {
        id: tabBar
        Layout.fillWidth: true
        TabButton {
            //% "Points"
            text: qsTrId("cup-text-points-title")
        }
        TabButton {
            //% "Polygons"
            text: qsTrId("cup-text-polygons-title")
        }
        TabButton {
            //% "Tracks"
            text: qsTrId("cup-text-tracks-title")
        }
    }

    StackLayout {
        id: stackLayout
        Layout.fillWidth: true
        Layout.fillHeight: true
        currentIndex: tabBar.currentIndex

        PointsList {
            id: pointsList;
            points: (tracksData !== undefined) ? tracksData.points : undefined;
            pointPidSelectedFromMap: tabView.pointPidSelectedFromMap
            newPointPosition: tabView.newPointPosition;
            mapCenterLat: tabView.mapCenterLat;
            mapCenterLon: tabView.mapCenterLon
            enableSnap: showTrackAlways;


            onNewPoints: {
                pointsUpdated(p);
            }

            onPointSelected: {
                pointListItemSelected(pid);
            }
            onSnapToSth: {
                pointSnap(pid);
            }

            onNewPolygon: {
                var newPoly = tracksData.poly;
                var maxCid = 0;
                for (var i = 0; i < newPoly.length; i++) {
                    var item = newPoly[i];
                    maxCid = Math.max(item.cid, maxCid);
                }
                p.cid = maxCid+1;
                newPoly.push(p);
                polygonsUpdated(newPoly);

            }

        }

        PolygonList {
            id: polygonList;
            polygons: (tracksData !== undefined) ? tracksData.poly : undefined;

            onNewPolygons: {
                polygonsUpdated(p);
            }
            onPolygonSelected: {
                polyListItemSelected(cid);
            }

            onPolygonToPoints: {
                var polys = tracksData.poly;

                var newArr = tracksData.points;
                var maxPid = 0;
                for (var i = 0; i < newArr.length; i++) {
                    var item = newArr[i];
                    maxPid = Math.max(item.pid, maxPid);
                }

                for (var i = 0; i < polys.length; i++) {
                    var poly = polys[i];
                    if (poly.cid === cid) {
                        var name = poly.name;
                        var polypoints = poly.points;
                        for (var j = 0; j < polypoints.length; j++) {
                            var newName = name + " " + j;
                            var polypoint = polypoints[j];
                            var item = {
                                "name" : newName,
                                "lat": polypoint.lat,
                                "lon": polypoint.lon,
                                "pid": maxPid+1+j,
                            }
                            newArr.push(item);


                        }

                        break;
                    }

                }
                pointsUpdated(newArr);
            }

        }

        TracksList {
            cupData: tracksData;
            onNewTracks: {
                tracksUpdated(t)
            }
            onCategoryChanged: {
                selectedCategoryIndex = index;
            }

            onPointSelected: {
                trackListItemSelected(tid)
            }

            computedData: tabView.computedData

        }
    }
}
