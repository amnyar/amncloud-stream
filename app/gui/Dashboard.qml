import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: dashboardRoot
    objectName: "DashboardView"
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#121212"

        ColumnLayout {
            anchors.fill: parent
            spacing: 16
            padding: 20

           
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "🎮 به بازی کلاد خوش آمدید"
                    font.pixelSize: 20
                    color: "white"
                    font.family: defaultFont
                    Layout.alignment: Qt.AlignLeft
                }

                Item { Layout.fillWidth: true } 

                Button {
                    id: settingsBtn
                    text: "تنظیمات"
                    font.family: defaultFont
                    background: Rectangle {
                        color: "#3f51b5"
                        radius: 8
                    }
                    onClicked: {
                        stackView.push("qrc:/gui/SettingsView.qml")
                    }
                }
            }

            Rectangle {
                height: 2
                width: parent.width
                color: "#2e2e2e"
                Layout.margins: 10
            }

            
            Text {
                text: "لیست بازی‌ها به زودی نمایش داده می‌شود . . ."
                font.pixelSize: 16
                color: "#cccccc"
                font.family: defaultFont
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Component.onCompleted: {
        if (typeof mainToolBar !== 'undefined') mainToolBar.visible = true
        if (typeof settingsButton !== 'undefined') settingsButton.visible = true
        if (typeof topMenu !== 'undefined') topMenu.visible = true
    }
}
