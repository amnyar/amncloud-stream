import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: root
    objectName: "RegisterUser"
    anchors.fill: parent

    property string phone: ""

    Rectangle {
        anchors.fill: parent
        color: "#121212"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "ثبت ‌نام کاربر جدید"
                color: "white"
                font.pixelSize: 18
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: phone
                color: "#aaaaaa"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
            }

            Button {
                text: "ثبت ‌نام و ارسال کد"
                Layout.preferredWidth: 250
                background: Rectangle {
                    color: "red"
                    radius: 10
                }

                onClicked: {
                    statusText.text = "در حال ثبت ‌نام..."
                    registerUser(phone)
                }
            }

            Text {
                id: statusText
                color: "white"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    function registerUser(phone) {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", "https://bazicloud.com/wp-json/amncloud/v1/send-code")
        xhr.setRequestHeader("Content-Type", "application/json")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    statusText.text = "کد ارسال شد"
                    stackView.push("qrc:/gui/VerifyCode.qml", { phone: phone })
                } else {
                    statusText.text = "خطا در ثبت ‌نام"
                }
            }
        }

        xhr.send(JSON.stringify({ phone: phone }))
    }
}
