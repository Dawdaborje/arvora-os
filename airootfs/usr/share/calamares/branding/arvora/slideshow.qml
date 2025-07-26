import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    function onActivate() {
        console.log("QML Component (default slideshow) activated");
        presentation.nextSlide();
    }

    Timer {
        id: advanceTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: presentation.nextSlide()
    }

    Slide {
        anchors.fill: parent
        anchors.verticalCenterOffset: 0

        Image {
            id: background
            anchors.fill: parent
            source: "slide1.png"
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: background.bottom
            text: qsTr("Welcome to Arvora OS", "main title")
            wrapMode: Text.WordWrap
            width: root.width
            horizontalAlignment: Text.Center
        }
    }

    Slide {
        anchors.fill: parent
        anchors.verticalCenterOffset: 0

        Image {
            id: background2
            anchors.fill: parent
            source: "slide2.png"
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: background2.bottom
            text: qsTr("Installing Arvora OS...", "main title")
            wrapMode: Text.WordWrap
            width: root.width
            horizontalAlignment: Text.Center
        }
    }

    Slide {
        anchors.fill: parent
        anchors.verticalCenterOffset: 0

        Image {
            id: background3
            anchors.fill: parent
            source: "slide3.png"
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: background3.bottom
            text: qsTr("Installation Complete!", "main title")
            wrapMode: Text.WordWrap
            width: root.width
            horizontalAlignment: Text.Center
        }
    }
}
