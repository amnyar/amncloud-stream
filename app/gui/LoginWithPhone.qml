import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: root
    objectName: "LoginWithPhone"
    anchors.fill: parent

    property bool showTopIcons: false
    property int timerSeconds: 0

    Timer {
        id: resendTimer
        interval: 1000
        repeat: true
        running: false
        onTriggered: {
            timerSeconds--
            if (timerSeconds <= 0) {
                resendTimer.stop()
                sendCodeBtn.enabled = true
                timerText.visible = false
            } else {
                timerText.text = "امکان ارسال مجدد تا " + timerSeconds + " ثانیه دیگر"
            }
        }
    }

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
                    text: "BAZI CLOUD"
                    font.pixelSize: 40
                    font.bold: true
                    color: "white"
                    font.family: defaultFont
                }
            }

            Text {
                text: "ورود با شماره موبایل"
                color: "white"
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                width: parent.width
                font.family: defaultFont
            }

            TextField {
                id: phoneInput
                focus: true
                placeholderText: "مثلاً 09121234567"
                Layout.preferredWidth: 250
                font.pixelSize: 16
                font.family: defaultFont
                inputMethodHints: Qt.ImhDigitsOnly
                echoMode: TextInput.Normal
                maximumLength: 11
                inputMask: "09999999999;_"
                validator: RegExpValidator { regExp: /^09[0-9]{0,9}$/ }
                horizontalAlignment: TextInput.AlignHCenter
                text: ""

                onTextChanged: {
                   
                    phoneInput.text = phoneInput.text.replace(/[۰-۹]/g, function(p) {
                        return String.fromCharCode(p.charCodeAt(0) - 1728)
                    })
                    statusText.text = ""
                    signupBtn.visible = false
                }
            }

            Button {
                id: sendCodeBtn
                text: "ارسال کد ورود"
                Layout.preferredWidth: 250
                enabled: true
                font.family: defaultFont
                background: Rectangle {
                    color: "red"
                    radius: 10
                }

                onClicked: {
                    if (!/^09[0-9]{9}$/.test(phoneInput.text)) {
                        statusText.text = "شماره وارد شده معتبر نیست"
                        signupBtn.visible = false
                        return
                    }

                    statusText.text = "در حال ارسال کد . . ."
                    sendCodeToApi(phoneInput.text)

                    timerSeconds = 59
                    resendTimer.start()
                    sendCodeBtn.enabled = false
                    timerText.visible = true
                }
            }

            Text {
                id: timerText
                visible: false
                color: "#cccccc"
                font.pixelSize: 13
                Layout.alignment: Qt.AlignHCenter
                font.family: defaultFont
            }

            Text {
                id: statusText
                color: "white"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.WrapAnywhere
                horizontalAlignment: Text.AlignHCenter
                font.family: defaultFont
            }

            Button {
                id: signupBtn
                text: "ثبت‌نام کنید"
                visible: false
                Layout.preferredWidth: 250
                font.family: defaultFont
                background: Rectangle {
                    color: "#43aa8b"
                    radius: 10
                }

                onClicked: {
                    stackView.push("qrc:/gui/Signup.qml", { phone: phoneInput.text })
                }
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
                    try {
                        var component = Qt.createComponent("qrc:/gui/VerifyCode.qml")
                        if (component.status === Component.Error) {
                            statusText.text = "فایل تأیید کد یافت نشد"
                            return
                        }

                        statusText.text = "کد با موفقیت ارسال شد"
                        stackView.push("qrc:/gui/VerifyCode.qml", { phone: phoneNumber })
                    } catch (e) {
                        statusText.text = "خطا در بارگذاری فایل VerifyCode"
                    }
                } else if (xhr.status === 404) {
                    statusText.text = "کاربری با این شماره پیدا نشد"
                    signupBtn.visible = true
                } else {
                    statusText.text = "خطا در ارسال کد . دوباره تلاش کنید"
                }
            }
        }

        xhr.send(JSON.stringify({ phone: phoneNumber }))
    }

    Component.onCompleted: {
        if (typeof mainToolBar !== 'undefined') mainToolBar.visible = false
        if (typeof settingsButton !== 'undefined') settingsButton.visible = false
        if (typeof topMenu !== 'undefined') topMenu.visible = false
    }
}
