import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtQuick.Window 2.15

Item {
    id: profileRoot
    objectName: "ProfileView"
    anchors.fill: parent

    property string userName: "در حال بارگذاری..."
    property string userIdentifier: "..."
    property url avatarUrl: "https://placehold.co/60x60/cccccc/000/png?text=AV" // Placeholder URL
    property int coinBalance: 0
    property int walletBalance: 0
    property string subscriptionStatus: "وضعیت نامشخص"
    property ListModel noticesModel: ListModel {}
    property Font defaultFont // Assume defined globally

    Rectangle {
        anchors.fill: parent
        color: "#121212"

        ColumnLayout {
            id: mainColumnLayout
            anchors.fill: parent
            spacing: 0

            Rectangle {
                id: topBarProfile
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#1e1e1e"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 15

                    Button {
                        id: backBtn
                        text: "< بازگشت"
                        font.family: defaultFont
                        font.pixelSize: 16
                        Layout.alignment: Qt.AlignVCenter
                        flat: true
                        onClicked: {
                            if (stackView.depth > 1) {
                                stackView.pop();
                            }
                        }
                        contentItem: Text { text: backBtn.text; font: backBtn.font; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }

                    Item { Layout.fillWidth: true }

                    Image {
                        id: logoProfile
                        source: "https://placehold.co/100x40/E74C3C/FFF/png?text=LOGO" // Placeholder URL
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40
                        fillMode: Image.PreserveAspectFit
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                Layout.margins: 20
                columns: 3
                columnSpacing: 20
                rowSpacing: 20

                Rectangle {
                    id: coinsArea
                    Layout.fillWidth: true; Layout.preferredHeight: 80; Layout.columnSpan: 1; color: "#2a2a2a"; radius: 8
                    RowLayout {
                       anchors.centerIn: parent; spacing: 10
                        Image { source: "https://placehold.co/40x40/FFD700/000/png?text=C"; width: 40; height: 40 } // Placeholder URL
                       ColumnLayout {
                            Text { text: "سکه ها"; color: "#cccccc"; font.pixelSize: 14; font.family: defaultFont }
                            Text { text: coinBalance; color: "white"; font.pixelSize: 18; font.bold: true; font.family: defaultFont }
                       }
                    }
                }
                 Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }
                Rectangle {
                    id: userInfoArea
                    Layout.fillWidth: true; Layout.preferredHeight: 80; Layout.columnSpan: 1; color: "transparent"
                    RowLayout {
                        anchors.verticalCenter: parent; anchors.right: parent.right; spacing: 15
                        ColumnLayout {
                            anchors.verticalCenter: parent
                            Text { text: "نام و نام خانوادگی"; color: "#cccccc"; font.pixelSize: 14; horizontalAlignment: Text.AlignRight; font.family: defaultFont }
                            Text { id: nameText; text: userName; color: "white"; font.pixelSize: 16; font.bold: true; horizontalAlignment: Text.AlignRight; font.family: defaultFont }
                            Text { id: identifierText; text: userIdentifier; color: "#aaaaaa"; font.pixelSize: 12; horizontalAlignment: Text.AlignRight; font.family: defaultFont }
                       }
                       Image {
                           id: avatarImage
                           source: avatarUrl
                           width: 60; height: 60; fillMode: Image.PreserveAspectCrop; asynchronous: true
                       }
                    }
                }

                Rectangle {
                    id: subscriptionArea
                    Layout.fillWidth: true; Layout.preferredHeight: 120; Layout.columnSpan: 1; color: "#2a2a2a"; radius: 8
                    ColumnLayout {
                        anchors.centerIn: parent; spacing: 10
                        Text { text: "وضعیت اشتراک"; color: "#cccccc"; font.pixelSize: 14; Layout.alignment: Qt.AlignHCenter; font.family: defaultFont }
                        Text { id: subStatusText; text: subscriptionStatus; color: "white"; font.pixelSize: 16; Layout.alignment: Qt.AlignHCenter; font.family: defaultFont }
                        Button { text: "خرید اشتراک"; font.family: defaultFont; Layout.alignment: Qt.AlignHCenter; background: Rectangle { color: "#555"; radius: 5 } }
                    }
                }

                 Rectangle {
                     id: walletArea
                     Layout.fillWidth: true; Layout.preferredHeight: 120; Layout.columnSpan: 2; color: "#2a2a2a"; radius: 8
                     ColumnLayout {
                         anchors.centerIn: parent; spacing: 10
                         Text { text: "موجودی کیف پول"; color: "#cccccc"; font.pixelSize: 14; Layout.alignment: Qt.AlignHCenter; font.family: defaultFont }
                         Text { id: walletText; text: walletBalance.toLocaleString(Qt.locale("fa_IR"), 'f', 0) + " تومان"; color: "white"; font.pixelSize: 20; font.bold: true; Layout.alignment: Qt.AlignHCenter; font.family: defaultFont }
                         Button { text: "شارژ کیف پول"; font.family: defaultFont; Layout.alignment: Qt.AlignHCenter; background: Rectangle { color: "red"; radius: 5 } }
                     }
                 }
            }

             ColumnLayout {
                 Layout.fillWidth: true; Layout.topMargin: 30; spacing: 10
                Text { text: "اطلاعیه ها"; color: "white"; font.pixelSize: 18; font.family: defaultFont; Layout.leftMargin: 20 }
                RowLayout {
                     Layout.fillWidth: true; Layout.leftMargin: 20; Layout.rightMargin: 20; spacing: 20
                     Repeater {
                         model: noticesModel
                         delegate: Rectangle {
                             width: (mainColumnLayout.width - (2*20) - (2*20) ) / 3; height: 100; color: "#2a2a2a"; radius: 8
                             property alias noticeUrl: model.url
                             RowLayout {
                                 anchors.fill: parent; anchors.margins: 10; spacing: 10
                                 Image {
                                     source: model.iconUrl; Layout.preferredWidth: 40; Layout.preferredHeight: 40; fillMode: Image.PreserveAspectFit; Layout.alignment: Qt.AlignVCenter; asynchronous: true
                                 }
                                 ColumnLayout {
                                      Layout.fillWidth: true; Layout.fillHeight: true
                                     Text { text: model.title; color: "white"; font.bold: true; font.family: defaultFont }
                                     Text { text: model.description; color: "#cccccc"; wrapMode: Text.WordWrap; font.family: defaultFont }
                                 }
                             }
                              MouseArea { anchors.fill: parent; onClicked: { if(noticeUrl) Qt.openUrlExternally(noticeUrl) } }
                         }
                     }
                }
             }

            Item { Layout.fillHeight: true }
             Text {
                 id: statusText
                 Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter; color: "yellow"; wrapMode: Text.Wrap; font.family: defaultFont
             }
        }
    }

    function fetchProfileData() {
        console.log("Attempting to fetch profile data...")
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://bazicloud.com/wp-json/amncloud/v1/profile");
        xhr.withCredentials = true;
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("Profile API response status:", xhr.status)
                if (xhr.status === 200) {
                    try {
                        var res = JSON.parse(xhr.responseText);
                        if (res.status === "success") {
                            userName = res.name || "نامشخص";
                            userIdentifier = res.email || "...";
                            avatarUrl = res.avatar || "https://placehold.co/60x60/cccccc/000/png?text=AV";
                            coinBalance = res.coins || 0;
                            walletBalance = res.wallet || 0;
                            statusText.text = "";
                            console.log("Profile data loaded successfully for:", userName);
                        } else {
                            statusText.text = "خطا در دریافت اطلاعات پروفایل: " + (res.message || "خطای نامشخص");
                            console.error("Profile API returned error:", res.message);
                        }
                    } catch (e) {
                        console.error("Failed to parse profile response:", e, xhr.responseText);
                        statusText.text = "خطا در پردازش اطلاعات پروفایل";
                    }
                } else if (xhr.status === 401 || xhr.status === 403) {
                     console.error("Profile API auth failed (status " + xhr.status + "). Cookies likely missing/invalid.");
                     statusText.text = "خطای احراز هویت. لطفاً دوباره وارد شوید.";
                } else {
                    console.error("Profile API request failed with status:", xhr.status);
                    statusText.text = "خطا در ارتباط با سرور برای دریافت پروفایل";
                }
            }
        }
        xhr.send();
    }

     function fetchNoticesData() {
         var xhr = new XMLHttpRequest();
         xhr.open("GET", "https://bazicloud.com/wp-json/amncloud/v1/notices");
         xhr.onreadystatechange = function() {
             if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                 try {
                     var res = JSON.parse(xhr.responseText);
                     noticesModel.clear();
                     for (var i = 0; i < res.length; i++) {
                         noticesModel.append({
                             title: res[i].title,
                             description: res[i].content,
                             iconUrl: getIconForNotice(res[i].title),
                             url: getUrlForNotice(res[i].content || res[i].title)
                         });
                     }
                 } catch (e) {
                     console.error("Failed to parse notices response:", e);
                 }
             }
         }
         xhr.send();
     }

     function getIconForNotice(title) {
         title = title.toLowerCase();
         if (title.includes("telegram")) return "https://placehold.co/40x40/2AABEE/FFF/png?text=TG"; // Telegram Blue
         if (title.includes("youtube")) return "https://placehold.co/40x40/FF0000/FFF/png?text=YT"; // YouTube Red
         if (title.includes("instagram")) return "https://placehold.co/40x40/E1306C/FFF/png?text=IG"; // Instagram Pink
         return "https://placehold.co/40x40/888/FFF/png?text=N";
     }
     function getUrlForNotice(text) {
         var urlRegex = /(https?:\/\/[^\s]+)/g;
         var match = text.match(urlRegex);
         return match ? match[0] : "https://bazicloud.com";
     }

    Component.onCompleted: {
         if (typeof mainToolBar !== 'undefined') mainToolBar.visible = false
         if (typeof settingsButton !== 'undefined') settingsButton.visible = false
         if (typeof topMenu !== 'undefined') topMenu.visible = false
         fetchProfileData();
         fetchNoticesData();
    }
}