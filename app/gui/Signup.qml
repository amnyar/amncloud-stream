import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: signupRoot
    objectName: "SignupView"
    anchors.fill: parent

    signal registrationSuccess // <--- سیگنال جدید تعریف شد

    property int secondsRemaining: 59
    property bool codeSent: false
    property string initialPhone: ""
    property Font defaultFont // Assume defined globally

    Rectangle {
        anchors.fill: parent
        color: "#121212"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 12

            Text {
                text: "ثبت ‌نام کاربر جدید"
                font.family: defaultFont; color: "white"; font.pixelSize: 20; horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: nameInput
                placeholderText: "نام"; font.family: defaultFont; Layout.preferredWidth: 250; font.pixelSize: 16; horizontalAlignment: TextInput.AlignHCenter
                visible: !codeSent
            }

            TextField {
                id: familyInput
                placeholderText: "نام خانوادگی"; font.family: defaultFont; Layout.preferredWidth: 250; font.pixelSize: 16; horizontalAlignment: TextInput.AlignHCenter
                 visible: !codeSent
            }

            TextField {
                id: emailInput
                placeholderText: "ایمیل"; font.family: defaultFont; Layout.preferredWidth: 250; font.pixelSize: 16; inputMethodHints: Qt.ImhEmailCharactersOnly; horizontalAlignment: TextInput.AlignHCenter
                 visible: !codeSent
            }

            TextField {
                id: phoneInput
                placeholderText: "شماره موبایل ( مثلاً  09121234567 )"; font.family: defaultFont; Layout.preferredWidth: 250; font.pixelSize: 16; maximumLength: 11; validator: RegExpValidator { regExp: /^09[0-9]{0,9}$/ }; inputMethodHints: Qt.ImhDigitsOnly; horizontalAlignment: TextInput.AlignHCenter
                text: initialPhone
                 visible: !codeSent
                 enabled: !codeSent
                onTextChanged: { phoneInput.text = phoneInput.text.replace(/[۰-۹]/g, function(p) { return String.fromCharCode(p.charCodeAt(0) - 1728) }) }
            }

            TextField {
                id: codeInput
                visible: codeSent
                placeholderText: "کد ۶ رقمی پیامک شده"; font.family: defaultFont; Layout.preferredWidth: 250; font.pixelSize: 16; inputMethodHints: Qt.ImhDigitsOnly; validator: RegExpValidator { regExp: /^[0-9]{6}$/ }; horizontalAlignment: TextInput.AlignHCenter
            }

            Button {
                id: registerBtn
                text: codeSent ? "تایید کد و ثبت ‌نام" : "ارسال کد تایید"; font.family: defaultFont; enabled: !resendTimer.running; Layout.preferredWidth: 250
                background: Rectangle { color: registerBtn.enabled ? "#00c853" : "#555555"; radius: 10 }
                onClicked: {
                    if (!codeSent) {
                        if (!/^09[0-9]{9}$/.test(phoneInput.text)) { statusText.text = "شماره موبایل نامعتبر است"; return }
                        if (emailInput.text.length < 5 || emailInput.text.indexOf("@") === -1) { statusText.text = "ایمیل نامعتبر است"; return }
                        if (nameInput.text.trim() === "" || familyInput.text.trim() === "") { statusText.text = "نام و نام خانوادگی را وارد کنید"; return }
                        statusText.text = "در حال ارسال کد تایید . . ."; registerBtn.enabled = false; secondsRemaining = 59; resendTimer.start(); sendCodeRequest()
                    } else {
                        if (!/^[0-9]{6}$/.test(codeInput.text)) { statusText.text = "کد وارد شده نامعتبر است"; return }
                        statusText.text = "در حال تایید کد و تکمیل ثبت نام . . ."; registerBtn.enabled = false; submitRegistration()
                    }
                }
            }

            Text {
                id: timerText
                visible: resendTimer.running && codeSent; font.family: defaultFont; text: "امکان ارسال مجدد تا " + secondsRemaining + " ثانیه دیگر"; color: "#bbbbbb"; font.pixelSize: 13; Layout.alignment: Qt.AlignHCenter
            }

            Button {
                id: loginInsteadBtn
                visible: false; text: "ورود به حساب"; font.family: defaultFont; Layout.preferredWidth: 250
                background: Rectangle { color: "#1976d2"; radius: 10 }
                onClicked: {
                     if (typeof stackView !== 'undefined') { stackView.clear(); stackView.push("qrc:/gui/LoginWithPhone.qml") } // This might still cause issues, better handled by main.qml
                     else { console.error("stackView (for loginInstead) is not defined/accessible from Signup.qml") }
                }
            }

            Text {
                id: statusText
                font.family: defaultFont; color: "white"; font.pixelSize: 14; wrapMode: Text.WrapAnywhere; horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    Timer {
        id: resendTimer
        interval: 1000; repeat: true; running: false
        onTriggered: { if (secondsRemaining > 0) { secondsRemaining-- } else { running = false; registerBtn.enabled = true } }
    }

    function sendCodeRequest() {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", "https://bazicloud.com/wp-json/amncloud/v1/request-registration-code")
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                 registerBtn.enabled = !resendTimer.running
                try {
                    var response = JSON.parse(xhr.responseText)
                    if (xhr.status === 200 && response.success === true) {
                        statusText.text = response.message || "کد تایید ارسال شد . لطفاً آن را وارد کنید"; codeSent = true; codeInput.focus = true
                    } else if (xhr.status === 409) {
                         resendTimer.stop(); registerBtn.enabled = true; statusText.text = response.message || "موبایل یا ایمیل قبلاً ثبت شده است."; loginInsteadBtn.visible = true
                    } else {
                         resendTimer.stop(); registerBtn.enabled = true; statusText.text = response.message || "خطای ناشناخته هنگام ارسال کد"
                    }
                } catch (e) {
                     resendTimer.stop(); registerBtn.enabled = true; statusText.text = "خطا در ارتباط با سرور یا پاسخ نامعتبر"
                     console.error("Error parsing request-reg response:", e, xhr.responseText);
                }
            }
        }
        xhr.send(JSON.stringify({ name: nameInput.text, family: familyInput.text, email: emailInput.text, phone: phoneInput.text }))
    }

    function submitRegistration() {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", "https://bazicloud.com/wp-json/amncloud/v1/complete-registration")
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                 registerBtn.enabled = true
                try {
                    var res = JSON.parse(xhr.responseText)
                    if (xhr.status === 200 && (res.success === true)) {
                        statusText.text = "✅ ثبت ‌نام با موفقیت انجام شد"
                        registrationSuccess() // <--- انتشار سیگنال به جای فراخوانی مستقیم
                    } else {
                        statusText.text = res.message || "کد اشتباه است یا منقضی شده یا خطای دیگری رخ داد"
                    }
                } catch (e) {
                    statusText.text = "❌ خطا در پردازش پاسخ سرور هنگام تایید کد"
                     console.error("Error parsing complete-reg response:", e, xhr.responseText);
                }
            }
        }
        xhr.send(JSON.stringify({ phone: phoneInput.text, code: codeInput.text }))
    }

    Component.onCompleted: {
        if (typeof mainToolBar !== 'undefined') mainToolBar.visible = false
        if (typeof settingsButton !== 'undefined') settingsButton.visible = false
        if (typeof topMenu !== 'undefined') topMenu.visible = false
        nameInput.forceActiveFocus()
    }
}