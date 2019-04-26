import QtQuick 2.9
import QtQuick.Controls 1.4

ApplicationWindow {
    id: window
    width: 600
    height: 250
    modality: Qt.ApplicationModal;

    signal accepted();
    signal canceled();


    property alias tp_count: turnpoints_number.text
    property alias tp_max_score: turnpoints_scoring_value.text
    property alias sg_count: spacegates_number.text
    property alias sg_max_score: spacegates_scoring_value.text
    property alias tg_count: timegates_number.text
    property alias tg_max_score: timegates_scoring_value.text
    property alias photos_score: photos_scoring_value.text
    property alias markers_score: markers_scoring_value.text
    property alias other_score: other_value_in_task.text


    Grid {
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: parent.top;
        anchors.bottom: buttonRow.top;
        anchors.margins: 10;
        spacing: 5

        columns: 5;

        NativeText {
            //% "Issue"
            text: qsTrId("track-statistics-issue")
        }
        NativeText {
            //% "Number"
            text: qsTrId("track-statistics-number")
        }
        NativeText {
            //% "Scoring value"
            text: qsTrId("track-statistics-scoring-value")
        }
        NativeText {
            //% "Value in task"
            text: qsTrId("track-statistics-value-in-task")
        }
        NativeText {
            //% "% of task value"
            text: qsTrId("track-statistics-percent-of-task-value")
        }

        /////


        NativeText {
            //% "Turn points"
            text: qsTrId("track-statistics-turn-point")
        }
        TextField {
            id: turnpoints_number
            text: "0"
        }
        TextField {
            id: turnpoints_scoring_value
            text: "0"
        }
        NativeText {
            // value in task
            id: turnpoints_value_in_task
            text: Math.round(parseFloat(turnpoints_number.text, 10) * parseFloat(turnpoints_scoring_value.text, 10),2)
        }
        NativeText {
            // % of task
            text: Math.round(100.0*parseFloat(turnpoints_value_in_task.text, 10)/parseFloat(total_score.text,10),2);
        }

        /////

        NativeText {
            //% "Time gates"
            text: qsTrId("track-statistics-time-gates")
        }
        TextField {
            id: timegates_number
            text: "0"
        }
        TextField {
            id: timegates_scoring_value
            text: "0"
        }
        NativeText {
            // value in task
            id: timegates_value_in_task
            text: Math.round(parseFloat(timegates_number.text, 10) * parseFloat(timegates_scoring_value.text, 10),2)
        }
        NativeText {
            // % of task
            text: Math.round(100.0*parseFloat(timegates_value_in_task.text, 10)/parseFloat(total_score.text,10),2);
        }

        /////

        NativeText {
            //% "Space gates"
            text: qsTrId("track-statistics-space-gates")
        }
        TextField {
            id: spacegates_number
            text: "0"
        }
        TextField {
            id: spacegates_scoring_value
            text: "0"

        }
        NativeText {
            // value in task
            id: spacegates_value_in_task
            text: Math.round(parseFloat(spacegates_number.text, 10) * parseFloat(spacegates_scoring_value.text, 10),2)
        }
        NativeText {
            // % of task
            text: Math.round(100.0*parseFloat(spacegates_value_in_task.text, 10)/parseFloat(total_score.text,10),2);
        }


        /////

        NativeText {
            //% "Markers"
            text: qsTrId("track-statistics-markers")
        }
        TextField {
            id: markers_number
            text: "0"
        }
        TextField {
            id: markers_scoring_value
            text: "0"
        }
        NativeText {
            // value in task
            id: markers_value_in_task
            text: Math.round(parseFloat(markers_number.text, 10) * parseFloat(markers_scoring_value.text, 10),2)
        }
        NativeText {
            // % of task
            text: Math.round(100.0*parseFloat(markers_value_in_task.text, 10)/parseFloat(total_score.text,10),2);
        }


        /////

        NativeText {
            //% "Photos"
            text: qsTrId("track-statistics-photos")
        }
        TextField {
            id: photos_number
            text: "0"
        }
        TextField {
            id: photos_scoring_value
            text: "0"
        }
        NativeText {
            // value in task
            id: photos_value_in_task
            text: Math.round(parseFloat(photos_number.text, 10) * parseFloat(photos_scoring_value.text, 10),2)
        }
        NativeText {
            // % of task
            text: Math.round(100.0*parseFloat(photos_value_in_task.text, 10)/parseFloat(total_score.text,10),2);
        }


        /////

        NativeText {
            //% "Other"
            text: qsTrId("track-statistics-other")
        }
        NativeText {
            text: "-"
        }

        NativeText {
            text: "-"

        }

        TextField {
            id: other_value_in_task
            text: "0"
        }

        NativeText {
            // % of task
            text: Math.round(100.0*parseFloat(other_value_in_task.text, 10)/parseFloat(total_score.text,10),2);
        }



        /////



        NativeText {
            //% "Total"
            text: qsTrId("track-statistics-total");
        }
        NativeText {
            text: " "
        }
        NativeText {
            text: " "
        }

        NativeText {
            id: total_score
            text: Math.round(parseFloat(turnpoints_value_in_task.text,10)
                             + parseFloat(timegates_value_in_task.text,10)
                             + parseFloat(spacegates_value_in_task.text,10)
                             + parseFloat(markers_value_in_task.text,10)
                             + parseFloat(photos_value_in_task.text,10)
                             + parseFloat(other_value_in_task.text,10)
                             , 2)
        }





    }

    Row {
        id: buttonRow

        anchors.bottom: parent.bottom;
        anchors.right: parent.right;
        anchors.margins: 10;
        spacing: 5;

        Button {
            //% "Ok"
            text: qsTrId("track-statistics-ok")
            onClicked: {
                window.visible = false;
                accepted();
            }
        }
        Button {
            //% "Cancel"
            text: qsTrId("track-statistics-cancel")
            onClicked: {
                window.visible = false;
                canceled();
            }
        }
    }
}
