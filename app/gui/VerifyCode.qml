import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: root
    objectName: "VerifyCode"
    anchors.fill: parent

    property string phone: ""

    Rectangle {
        anchors.fill: parent
        color: "#121212"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "کد پیامک شده را وارد کنید"
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

            TextField {
                id: codeInput
                placeholderText: "کد ۶ رقمی"
                Layout.preferredWidth: 250
                font.pixelSize: 16
                inputMethodHints: Qt.ImhDigitsOnly
            }

            Button {
                text: "تایید و ورود"
                Layout.preferredWidth: 250
                background: Rectangle {
                    color: "red"
                    radius: 10
                }

                onClicked: {
                    if (codeInput.text.length < 4) {
                        statusText.text = "کد معتبر نیست"
                        return
                    }

                    statusText.text = "در حال بررسی . . ."
                    verifyCodeApi(phone, codeInput.text)
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

    function verifyCodeApi(phone, code) {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", "https://bazicloud.com/wp-json/amncloud/v1/verify-code")
        xhr.setRequestHeader("Content-Type", "application/json")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    statusText.text = "✅ ورود موفق !"
                } else {
                    statusText.text = "کد اشتباه است یا منقضی شده"
                }
            }
        }

        xhr.send(JSON.stringify({ phone: phone, code: code }))
    }
}
