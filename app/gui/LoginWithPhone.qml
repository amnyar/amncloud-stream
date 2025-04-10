import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: root
    objectName: "LoginWithPhone"
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#121212" 

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Rectangle {
                width: 250
                height: 100
                color: "red"
                radius: 20
                Layout.alignment: Qt.AlignHCenter

                Text {
                    anchors.centerIn: parent
                    text: "RESTIC"
                    font.pixelSize: 40
                    font.bold: true
                    color: "white"
                }
            }

            Text {
                text: "ورود با شماره موبایل"
                color: "white"
                font.pixelSize: 18
                Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: phoneInput
                placeholderText: "مثلاً 09121234567"
                Layout.preferredWidth: 250
                font.pixelSize: 16
                inputMethodHints: Qt.ImhDigitsOnly
            }

            Button {
                text: "ارسال کد ورود"
                Layout.preferredWidth: 250
                background: Rectangle {
                    color: "red"
                    radius: 10
                }
                onClicked: {
                    if (phoneInput.text.length < 11) {
                        statusText.text = "شماره وارد شده معتبر نیست"
                        return
                    }

                    statusText.text = "در حال ارسال کد . . ."
                    sendCodeToApi(phoneInput.text)
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

    function sendCodeToApi(phoneNumber) {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", "https://bazicloud.com/wp-json/amncloud/v1/send-code")
        xhr.setRequestHeader("Content-Type", "application/json")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    statusText.text = "کد با موفقیت ارسال شد"
                    stackView.push("qrc:/gui/VerifyCode.qml", { phone: phoneNumber })
                } else {
                    statusText.text = "خطا در ارسال کد . دوباره تلاش کنید"
                }
            }
        }

        xhr.send(JSON.stringify({ phone: phoneNumber }))
    }
}
