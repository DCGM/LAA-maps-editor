import QtQuick 2.9
import QtQuick.Controls 1.4


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
                //% "Build %1 %2 %3"
                text: qsTrId("about-build-date").arg(builddate).arg(buildtime).arg(version);
                anchors.left: parent.left
                anchors.right: parent.right
                wrapMode: Text.WordWrap
            }


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

BUT OPEN SOURCE LICENCE
Version 1.
Copyright (c) 2013-2015, Brno University of Technology, Antonínská 548/1, 601 90, Czech Republic <br/>
----- <br/>
BY INSTALLING, COPYING OR OTHER USES OF SOFTWARE YOU ARE DECLARING THAT YOU AGREE WITH THE TERMS AND CONDITIONS OF THIS LICENCE AGREEMENT. IF YOU DO NOT AGREE WITH THE TERMS AND CONDITIONS, DO NOT INSTAL, COPY OR USE THE SOFTWARE.
IF YOU DO NOT POSESS A VALID LICENCE, YOU ARE NOT AUTHORISED TO INSTAL, COPY OR OTHERWISE USE THE SOTWARE. <br/>
Definitions: <br/>
For the purpose of this agreement, Software shall mean a computer program (a group of computer programs functional as a unit) capable of copyright protection and accompanying documentation.
Work based on Software shall mean a work containing Software or a portion of it, either verbatim or with modifications and/or translated into another language, or a work based on Software. Portions of work not containing a portion of Software or not based on Software are not covered by this definition, if it is capable of independent use and distributed separately.
Source code shall mean all the source code for all modules of Software, plus any associated interface definition files, plus the scripts used to control compilation and installation of the executable program. Source code distributed with Software need not include anything that is normally distributed (in either source or binary form) with the major components (compiler, kernel, and so on) of the operating system on which the executable program runs.
Anyone who uses Software becomes User. User shall abide by this licence agreement. </br>
BRNO UNIVERSITY OF TECHNOLOGY GRANTS TO USER A LICENCE TO USE SOFTWARE ON THE FOLLOWING TERMS AND CONDITIONS: <br/>
User may use Software for any purpose, commercial or non-commercial, without a need to pay any licence fee. <br/>
User may copy and distribute verbatim copies of executable Software with source code as he/she received it, in any medium, provided that User conspicuously and appropriately publishes on each copy an appropriate copyright notice and disclaimer of warranty; keeps intact all the notices that refer to this licence and to the absence of any warranty; and give any other recipients of Software a copy of this licence along with Software. User may charge a fee for the physical act of transferring a copy, and may offer warranty protection in exchange for a fee.
User may modify his/her copy or copies of Software or any portion of it, thus forming a work based on Software, and copy and distribute such modifications or work, provided that User clearly states this work is modified Software. These modifications or work based on software may be distributed only under the terms of section 2 of this licence agreement, regardless if it is distributed alone or together with other work. Previous sentence does not apply to mere aggregation of another work not based on software with Software (or with a work based on software) on a volume of a storage or distribution medium.
User shall accompany copies of Software or work based on software in object or executable form with: <br/>
a) the complete corresponding machine-readable source code, which must be distributed on a medium customarily used for software interchange; or,
b) written offer, valid for at least three years, to give any third party, for a charge no more than actual cost of physically performing source distribution, a complete machine-readable copy of the corresponding source code, to be distributed on a medium customarily used for software interchange; or,
c) the information User received as to the offer to distribute corresponding source code. (This alternative is allowed only for noncommercial distribution and only if User received the program in objects code or executable form with such an offer, in accord with subsection b above.)
User may not copy, modify, grant sublicences or distribute Software in any other way than expressly provided for in this licence agreement. Any other copying, modifying, granting of sublicences or distribution of Software is illegal and will automatically result in termination of the rights granted by this licence. This does not affect rights of third parties acquired in good faith, as long as they abide by the terms and conditions of this licence agreement.
User may not use and/or distribute Software, if he/she cannot satisfy simultaneously obligations under this licence and any other pertinent obligations.
User is not responsible for enforcing terms of this agreement by third parties. <br/>
BECAUSE SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING, BUT PROVIDES SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND,EITHER EXPRESSED OR IMPLIED,INCLUDING,BUT NOT LIMITED TO,THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF SOFTWARE IS WITH USER. SHOULD SOFTWARE PROVE DEFECTIVE, USER SHALL ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.
IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL BRNO UNIVERSITY OF TECHNOLOGY BE LIABLE FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF SOFTWARE TO OPERATE WITH ANY OTHER PROGRAMS). <br/>
Final provisions: <br/>
Any provision of this licence agreement that is prohibited, unenforceable, or not authorized in any jurisdiction shall, as to such jurisdiction, be ineffective to the extent of such prohibition, unenforceability, or non-authorization without invalidating or affecting the remaining provisions.
This licence agreement provides in essentials the same extent of rights as the terms of GNU GPL version 2 and Software fulfils the requirements of Open Source software.
This agreement is governed by law of the Czech Republic. In case of a dispute, the jurisdiction shall be that of courts in the Czech Republic.
By installing, copying or other use of Software User declares he/she has read this terms and conditions, understands them and his/her use of Software is a demonstration of his/her free will absent of any duress.
"
              */
                text: qsTrId("about-licence")

                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
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
