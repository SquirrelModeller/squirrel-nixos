import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import "./visual/Theme.js" as Theme

Label {
    id: clock
    property var date: new Date()

//    anchors {
//	horizontalCenter: parent.horizontalCenter
//	top: parent.top
//	topMargin: 100
//    }

    renderType: Text.NativeRendering
    font.pointSize: 20
    color: "white"

    Timer {
	running: true
	repeat: true
	interval: 1000

	onTriggered: clock.date = new Date();
    }

    text: {
	const hours = this.date.getHours().toString().padStart(2, '0');
	const minutes = this.date.getMinutes().toString().padStart(2, '0');
	return `${hours}:${minutes}`;
    }
}
