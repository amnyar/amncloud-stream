import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: root
    objectName: "VerifyCode"
    anchors.fill: parent

    signal loginSuccess

    property string phone: ""
    property int secondsRemaining: 59
    property Font defaultFont // Assume defined globally

    Rectangle {
        anchors.fill: parent
        color: "#121212"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "کد پیامک شده را وارد کنید"
                color: "white"; font.pixelSize: 18; Layout.alignment: Qt.AlignHCenter; font.family: defaultFont
            }

            Text {
                text: phone
                color: "#aaaaaa"; font.pixelSize: 14; Layout.alignment: Qt.AlignHCenter; font.family: defaultFont
            }

            TextField {
                id: codeInput
                placeholderText: "کد ۶ رقمی"; Layout.preferredWidth: 250; font.pixelSize: 16; font.family: defaultFont
                inputMethodHints: Qt.ImhDigitsOnly; validator: RegExpValidator { regExp: /^[0-9]{6}$/ }; horizontalAlignment: TextInput.AlignHCenter
                focus: true
            }

            Button {
                id: verifyBtn
                text: "تأیید و ورود"; Layout.preferredWidth: 250; font.family: defaultFont
                background: Rectangle { color: "red"; radius: 10 }
                enabled: true

                onClicked: {
                    if (!/^[0-9]{6}$/.test(codeInput.text)) {
                        statusText.text = "کد معتبر نیست"
                        return
                    }
                    statusText.text = "در حال بررسی . . ."
                    verifyBtn.enabled = false
                    resendButton.enabled = false
                    verifyCodeApi(phone, codeInput.text)
                }
            }

            Text {
                id: statusText
                color: "white"; font.pixelSize: 14; Layout.alignment: Qt.AlignHCenter; wrapMode: Text.WrapAnywhere; horizontalAlignment: Text.AlignHCenter; font.family: defaultFont
            }

            Text {
                id: timerText
                visible: resendTimer.running
                text: "ارسال مجدد تا " + secondsRemaining + " ثانیه دیگر"; color: "#bbbbbb"; font.pixelSize: 13; Layout.alignment: Qt.AlignHCenter; font.family: defaultFont
            }

            Button {
                id: resendButton
                text: "ارسال مجدد کد"; visible: !resendTimer.running; Layout.preferredWidth: 250; font.family: defaultFont
                background: Rectangle { color: "#00c853"; radius: 10 }
                enabled: true

                onClicked: {
                    resendButton.enabled = false
                    verifyBtn.enabled = false
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
        interval: 1000; repeat: true; running: false
        onTriggered: {
            if (secondsRemaining > 0) {
                secondsRemaining--
            } else {
                running = false
                resendButton.visible = true
                resendButton.enabled = true
                verifyBtn.enabled = true
            }
        }
    }

    function verifyCodeApi(phone, code) {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", "https://bazicloud.com/wp-json/amncloud/v1/verify-code")
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.withCredentials = true;

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                verifyBtn.enabled = true
                resendButton.enabled = !resendTimer.running

                try {
                    var res = JSON.parse(xhr.responseText)
                    if (xhr.status === 200 && (res.success === true)) {
                        statusText.text = "✅ ورود با موفقیت انجام شد"
                        loginSuccess() // Emit signal
                    } else {
                        statusText.text = res.message || "کد اشتباه است یا منقضی شده"
                    }
                } catch (e) {
                    statusText.text = "❌ خطا در پردازش پاسخ سرور"
                    console.error("Error parsing verify-code response:", e, xhr.responseText);
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
                     try {
                         var res = JSON.parse(xhr.responseText);
                         if(res.success === true) {
                             statusText.text = "کد مجدداً ارسال شد"
                         } else {
                             statusText.text = res.message || "خطا در ارسال مجدد کد (سرور)"
                             resendTimer.stop(); resendButton.visible = true; resendButton.enabled = true; verifyBtn.enabled = true;
                         }
                     } catch(e) {
                          statusText.text = "خطا در پردازش پاسخ ارسال مجدد";
                          resendTimer.stop(); resendButton.visible = true; resendButton.enabled = true; verifyBtn.enabled = true;
                     }

                } else {
                    statusText.text = "خطا در ارسال مجدد کد ("+xhr.status+")"
                     resendTimer.stop(); resendButton.visible = true; resendButton.enabled = true; verifyBtn.enabled = true;
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
        codeInput.forceActiveFocus()
    }
}