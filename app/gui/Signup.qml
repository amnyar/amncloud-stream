import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: signupRoot
    objectName: "SignupView"
    anchors.fill: parent

    property int secondsRemaining: 59

    Rectangle {
        anchors.fill: parent
        color: "#121212"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 12

            Text {
                text: "ثبت نام کاربر جدید"
                color: "white"
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: nameInput
                placeholderText: "نام"
                Layout.preferredWidth: 250
                font.pixelSize: 16
                horizontalAlignment: TextInput.AlignHCenter
            }

            TextField {
                id: familyInput
                placeholderText: "نام خانوادگی"
                Layout.preferredWidth: 250
                font.pixelSize: 16
                horizontalAlignment: TextInput.AlignHCenter
            }

            TextField {
                id: emailInput
                placeholderText: "ایمیل"
                Layout.preferredWidth: 250
                font.pixelSize: 16
                inputMethodHints: Qt.ImhEmailCharactersOnly
                horizontalAlignment: TextInput.AlignHCenter
            }

            TextField {
                id: phoneInput
                placeholderText: "شماره موبایل ( مثلاً 09121234567 )"
                Layout.preferredWidth: 250
                font.pixelSize: 16
                maximumLength: 11
                validator: RegExpValidator { regExp: /^09[0-9]{0,9}$/ }
                inputMethodHints: Qt.ImhDigitsOnly
                horizontalAlignment: TextInput.AlignHCenter
                text: ""
            }

            Button {
                id: registerBtn
                text: "ارسال اطلاعات ثبت ‌نام"
                enabled: !resendTimer.running
                Layout.preferredWidth: 250
                background: Rectangle {
                    color: resendTimer.running ? "#555555" : "#00c853"
                    radius: 10
                }

                onClicked: {
                    if (!/^09[0-9]{9}$/.test(phoneInput.text)) {
                        statusText.text = "شماره موبایل نامعتبر است"
                        return
                    }
                    if (emailInput.text.length < 5 || emailInput.text.indexOf("@") === -1) {
                        statusText.text = "ایمیل نامعتبر است"
                        return
                    }
                    if (nameInput.text.trim() === "" || familyInput.text.trim() === "") {
                        statusText.text = "نام و نام خانوادگی را وارد کنید"
                        return
                    }

                    statusText.text = "در حال ارسال اطلاعات . . ."
                    secondsRemaining = 59
                    resendTimer.start()
                    registerUser()
                }
            }

            Text {
                id: timerText
                visible: resendTimer.running
                text: "امکان ارسال مجدد تا " + secondsRemaining + " ثانیه دیگر"
                color: "#bbbbbb"
                font.pixelSize: 13
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                id: statusText
                color: "white"
                font.pixelSize: 14
                wrapMode: Text.WrapAnywhere
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    Timer {
        id: resendTimer
        interval: 1000
        repeat: true
        running: false

        onTriggered: {
            if (secondsRemaining > 0) {
                secondsRemaining--
            } else {
                running = false
            }
        }
    }

    function registerUser() {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", "https://bazicloud.com/wp-json/amncloud/v1/register")
        xhr.setRequestHeader("Content-Type", "application/json")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        if (response.status === "exists") {
                            statusText.text = "شما قبلاً ثبت‌ نام کرده‌اید"
                        } else if (response.status === "success") {
                            statusText.text = "ثبت ‌نام موفق بود. ارسال کد تأیید . . ."
                            stackView.push("qrc:/gui/VerifyCode.qml", { phone: phoneInput.text })
                        } else {
                            statusText.text = response.message || "خطای ناشناخته هنگام ثبت‌ نام"
                        }
                    } catch (e) {
                        statusText.text = "خطا در پردازش پاسخ سرور"
                    }
                } else {
                    statusText.text = "ثبت ‌نام انجام نشد . مجدد تلاش کنید"
                }
            }
        }

        xhr.send(JSON.stringify({
            name: nameInput.text,
            family: familyInput.text,
            email: emailInput.text,
            phone: phoneInput.text
        }))
    }

    Component.onCompleted: {
        if (typeof mainToolBar !== 'undefined') mainToolBar.visible = false
        if (typeof settingsButton !== 'undefined') settingsButton.visible = false
        if (typeof topMenu !== 'undefined') topMenu.visible = false
    }
}
