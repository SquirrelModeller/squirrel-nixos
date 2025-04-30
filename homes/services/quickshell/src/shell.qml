import QtQuick 2.15
import Quickshell
import Quickshell.Hyprland
import QtQuick.Layouts
import "./visual/Theme.js" as Theme


ShellRoot {
    PanelWindow {
	id: root
	anchors {
	    top: true
	    left: true
	    right: true
	}
        color: "transparent"
        height: 70
	

        RowLayout {
            anchors.fill: parent
	    uniformCellSizes: true
	    Layout.margins: 20

            Rectangle {
		Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
		Layout.preferredWidth: childrenRect.width
		Layout.preferredHeight: childrenRect.height
		Layout.margins: parent.Layout.margins
		color: Theme.transparentBackground
                radius: 100
                Row {
                    Repeater {
                        model: 10
                        delegate: WorkspaceIndicator {
                            workspaceIndex: model.index + 1
                        }
                    }
                }
            }

            WindowName {
		Layout.alignment: Qt.AlignHCenter
		Layout.preferredWidth: childrenRect.width
            }

	    SysTray {
		Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
		Layout.margins: parent.Layout.margins 
	    }
        }
    }

    function dub(x: int): int {
        for (var i = 0; i < 10; i+=1) {
            console.log("hi");
        }
        return x * 2;
    }

    function testSysTray() {
	
    }
}
