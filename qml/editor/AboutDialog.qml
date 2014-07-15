import QtQuick 2.2
import QtQuick.Controls 1.2


ApplicationWindow {
    id: dialog
    width: 600;
    height: 400;
    modality: "WindowModal"


    NativeText {
        id: titleLabel;
        font.pixelSize: 36;
        //% "LAA Trajectory Editor"
        text: qsTrId("about-app-title")
        anchors.top: parent.top
        anchors.left: parent.left;
        anchors.right: parent.right;
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        anchors.margins: 10;

    }


    Rectangle {
        id: flickableScrollDecorator
        color: "#ffffff"
        border.color: "#cccccc"
        border.width: 1
        anchors.right: flickable.right
        y: flickable.y + (flickable.contentY/flickable.contentHeight) * flickable.height
        width: 3
        height: (flickable.height / flickable.contentHeight) * flickable.height
        visible: height < flickable.height
    }



    Flickable {

        id: flickable
        anchors.top: titleLabel.bottom
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: logoRectangle.top
        contentHeight: contentItem.childrenRect.height
        clip: true

        Column {
            id: column
            anchors.left: parent.left;
            anchors.right: parent.right
            spacing: 20;
            anchors.margins: 10;


            NativeText {
                id: aboutTextLabel

                 anchors.left: parent.left
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                /*% "
Authors: <br/>\n
Jozef Mlich, Adam Siroky, Pavel Zemcik, <a href=\"http://www.fit.vutbr.cz/\">FIT VUT Brno</a> <br/> <br/>\n\n

Licence: <br/>\n

 Copyright (C) 2013-2014 Brno University of Technology.
 All rights reserved. <br/> <br/>

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:<br/>
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.<br/>
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the
      distribution.<br/>
    * Neither the name of Brno University of Technology nor
      the names of its contributors may be used to endorse or promote
      products derived from this software without specific prior written
      permission.<br/><br/>

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 "
              */
                text: qsTrId("about-licence")

                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
            }
            NativeText {
                //% "Build %1 %2"
                text: qsTrId("about-build-date").arg(builddate).arg(buildtime);
                anchors.left: parent.left
                anchors.right: parent.right
                wrapMode: Text.WordWrap
            }

        }

    }

    Rectangle {
        id: logoRectangle
        anchors.bottom: parent.bottom;

        height: 100;
        width: parent.width;
        color: "#ffffff"


        Row {
            anchors.fill: parent;
            anchors.margins: 10;
            Image {
                height: parent.height-20
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                source: "./data/logo-laa.png"
            }
            Image {
                height: parent.height-20
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                source: "./data/logo_fit.png"
            }
        }

    }


}
