import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: root
    objectName: "VerifyCode"
    anchors.fill: parent

    property string phone: ""
    property int secondsRemaining: 59

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
                validator: RegExpValidator { regExp: /^[0-9]{6}$/ }
                horizontalAlignment: TextInput.AlignHCenter
            }

            Button {
                text: "تایید و ورود"
                Layout.preferredWidth: 250
                background: Rectangle {
                    color: "red"
                    radius: 10
                }

                onClicked: {
                    if (!/^[0-9]{6}$/.test(codeInput.text)) {
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
                wrapMode: Text.WrapAnywhere
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: timerText
                visible: resendTimer.running
                text: "ارسال مجدد تا " + secondsRemaining + " ثانیه دیگر"
                color: "#bbbbbb"
                font.pixelSize: 13
                Layout.alignment: Qt.AlignHCenter
            }

            Button {
                id: resendButton
                text: "ارسال مجدد کد"
                visible: !resendTimer.running
                Layout.preferredWidth: 250
                background: Rectangle {
                    color: "#00c853"
                    radius: 10
                }

                onClicked: {
                    resendButton.visible = false
                    secondsRemaining = 59
                    resendTimer.start()
                    statusText.text = "در حال ارسال کد جدید . . ."
                    sendCodeAgain(phone)
                }
            }
        }
    }

    Timer {
        id: resendTimer
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            if (secondsRemaining > 0) {
                secondsRemaining--
            } else {
                running = false
                resendButton.visible = true
            }
        }
    }

    function verifyCodeApi(phone, code) {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", "https://bazicloud.com/wp-json/amncloud/v1/verify-code")
        xhr.setRequestHeader("Content-Type", "application/json")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                try {
                    var res = JSON.parse(xhr.responseText)

                    if (res.status === "success" || res.success === true) {
                        statusText.text = "✅ ثبت ‌نام یا ورود با موفقیت انجام شد"
                        stackView.clear()
                        stackView.push("qrc:/gui/main.qml")
                    } else {
                        statusText.text = res.message || "کد اشتباه است یا منقضی شده"
                    }
                } catch (e) {
                    statusText.text = "❌ خطا در پردازش پاسخ سرور"
                }
            }
        }

        xhr.send(JSON.stringify({ phone: phone, code: code }))
    }

    function sendCodeAgain(phoneNumber) {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", "https://bazicloud.com/wp-json/amncloud/v1/send-code")
        xhr.setRequestHeader("Content-Type", "application/json")

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    statusText.text = "کد مجدداً ارسال شد"
                } else {
                    statusText.text = "خطا در ارسال مجدد کد"
                }
            }
        }

        xhr.send(JSON.stringify({ phone: phoneNumber }))
    }

    Component.onCompleted: {
        if (typeof mainToolBar !== 'undefined') mainToolBar.visible = false
        if (typeof settingsButton !== 'undefined') settingsButton.visible = false
        if (typeof topMenu !== 'undefined') topMenu.visible = false


        resendTimer.start()
        resendButton.visible = false
    }
}
