import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: dashboardRoot
    objectName: "DashboardView"
    anchors.fill: parent
    implicitHeight: 600
    implicitWidth: 1000

    property Font defaultFont // Assume defined globally

    Rectangle {
        anchors.fill: parent
        color: "#121212"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                id: topBar
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#1e1e1e"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 15

                    Image {
                        id: logo
                        source: "https://placehold.co/100x40/E74C3C/FFF/png?text=LOGO" // Placeholder URL
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40
                        fillMode: Image.PreserveAspectFit
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        id: searchBtn
                        // Use text or placeholder icon URL if available
                        // icon.source: "https://placehold.co/24x24/ffffff/000000/png?text=S"
                        text: "?" // Placeholder Text
                        font.pointSize: 16
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignVCenter
                        flat: true
                    }
                    Button {
                        id: notificationBtn
                         // Use text or placeholder icon URL if available
                        // icon.source: "https://placehold.co/24x24/ffffff/000000/png?text=N"
                        text: "🔔" // Placeholder Emoji
                        font.pointSize: 16
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignVCenter
                        flat: true
                    }
                     Button {
                         id: profileBtn
                         // Use text or placeholder icon URL if available
                         source: "https://placehold.co/40x40/cccccc/000000/png?text=U" // Placeholder URL
                         Image { anchors.fill: parent; source: parent.source; fillMode: Image.PreserveAspectFit } // Display image inside button
                         Layout.preferredWidth: 40
                         Layout.preferredHeight: 40
                         Layout.alignment: Qt.AlignVCenter
                         flat: true
                         onClicked: {
                              // stackView.push("qrc:/gui/Profile.qml")
                         }
                     }
                }
            }

            Item {
                id: bannerItem
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.4
                clip: true

                Image {
                    id: bannerBackground
                    anchors.fill: parent
                    source: "https://placehold.co/1280x300/555555/FFF/png?text=Banner+Image" // Placeholder URL
                    fillMode: Image.PreserveAspectCrop
                }

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#00000000" }
                        GradientStop { position: 0.7; color: "#80000000" }
                        GradientStop { position: 1.0; color: "#D0000000" }
                    }
                    anchors.top: undefined
                    height: parent.height * 0.5
                    anchors.bottom: parent.bottom
                }

                 ColumnLayout {
                     anchors.left: parent.left
                     anchors.bottom: parent.bottom
                     anchors.leftMargin: 30
                     anchors.bottomMargin: 30
                     spacing: 5

                     Text {
                         text: "GAME TITLE BANNER" // Placeholder Text
                         font.pixelSize: 36
                         font.bold: true
                         color: "white"
                         font.family: defaultFont
                     }
                     Text {
                         text: "Game tagline or description here..." // Placeholder Text
                         font.pixelSize: 18
                         color: "#dddddd"
                         font.family: defaultFont
                     }
                 }

                 RowLayout {
                     anchors.right: parent.right
                     anchors.verticalCenter: parent.verticalCenter
                     anchors.rightMargin: 30
                     spacing: 15

                    // Using Text placeholders for icons as URL finding is complex/unstable
                    Text { text: "📅"; font.pixelSize: 20; color: "white" } // Calendar Emoji
                    Text { text: "🎮"; font.pixelSize: 20; color: "white" } // Controller Emoji
                    Text { text: "VI"; color: "white"; font.bold: true; font.pixelSize: 16; font.family: defaultFont }
                    Text { text: "۱۲"; color: "white"; font.bold: true; font.pixelSize: 16; font.family: defaultFont }

                 }
                 Button {
                     id: bannerButton
                     text: "کلیک کنید"
                     anchors.right: parent.right
                     anchors.bottom: parent.bottom
                     anchors.rightMargin: 30
                     anchors.bottomMargin: 30
                     font.family: defaultFont
                 }
            }

             ColumnLayout {
                 Layout.fillWidth: true
                 Layout.fillHeight: true
                 Layout.topMargin: 20
                 Layout.leftMargin: 20
                 Layout.rightMargin: 20
                 spacing: 15

                Button {
                    id: allGamesBtn
                    text: "همه بازی ها"
                    font.family: defaultFont
                    Layout.alignment: Qt.AlignLeft
                    background: Rectangle { color: "#333333"; radius: 15; border.color: "#555555"; border.width: 1 }
                    contentItem: Text { text: allGamesBtn.text; font: allGamesBtn.font; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    padding: 10; leftPadding: 20; rightPadding: 20
                 }

                 Item {
                      Layout.fillWidth: true
                      Layout.fillHeight: true

                      ListView {
                          id: gameListView
                          anchors.fill: parent
                          anchors.leftMargin: 40
                          anchors.rightMargin: 40
                          orientation: ListView.Horizontal
                          clip: true
                          spacing: 15
                          model: gameListModel
                          delegate: gameDelegate
                          interactive: true
                          ScrollIndicator.horizontal: ScrollIndicator {}
                      }

                       Button {
                           id: leftArrow
                           anchors.left: parent.left
                           anchors.verticalCenter: parent.verticalCenter
                           text: "<"
                           font.pointSize: 16
                           width: 35; height: 60
                           background: Rectangle { color: "#444444"; radius: 5; opacity: 0.7 }
                           onClicked: { if (gameListView.currentIndex > 0) { gameListView.decrementCurrentIndex() } }
                           enabled: gameListView.currentIndex > 0
                       }

                       Button {
                           id: rightArrow
                           anchors.right: parent.right
                           anchors.verticalCenter: parent.verticalCenter
                           text: ">"
                           font.pointSize: 16
                           width: 35; height: 60
                           background: Rectangle { color: "#444444"; radius: 5; opacity: 0.7 }
                           onClicked: { if (gameListView.currentIndex < gameListView.count - 1) { gameListView.incrementCurrentIndex() } }
                           enabled: gameListView.currentIndex < gameListView.count - 1
                       }
                 }
             }
        }
    }

    ListModel {
         id: gameListModel
         ListElement { gameTitle: "Game 1"; posterUrl: "https://placehold.co/150x220/777/FFF/png?text=Game+1" }
         ListElement { gameTitle: "Game 2"; posterUrl: "https://placehold.co/150x220/888/FFF/png?text=Game+2" }
         ListElement { gameTitle: "Game 3"; posterUrl: "https://placehold.co/150x220/999/FFF/png?text=Game+3" }
         ListElement { gameTitle: "Game 4"; posterUrl: "https://placehold.co/150x220/AAA/FFF/png?text=Game+4" }
         ListElement { gameTitle: "Game 5"; posterUrl: "https://placehold.co/150x220/BBB/FFF/png?text=Game+5" }
         ListElement { gameTitle: "Game 6"; posterUrl: "https://placehold.co/150x220/CCC/000/png?text=Game+6" }
         ListElement { gameTitle: "Game 7"; posterUrl: "https://placehold.co/150x220/DDD/000/png?text=Game+7" }
         ListElement { gameTitle: "Game 8"; posterUrl: "https://placehold.co/150x220/EEE/000/png?text=Game+8" }
         ListElement { gameTitle: "Game 9"; posterUrl: "https://placehold.co/150x220/FFF/000/png?text=Game+9" }
    }

    Component {
         id: gameDelegate
         Item {
             width: 150
             height: 220

             Image {
                 id: posterImage
                 anchors.fill: parent
                 source: posterUrl
                 fillMode: Image.PreserveAspectCrop
                 smooth: true
                 asynchronous: true // Good for network images
             }

             Rectangle {
                 anchors.fill: parent
                 color: "transparent"
                 border.color: activeFocus ? "lightblue" : "transparent"
                 border.width: 2
             }
              MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                      console.log("Clicked game:", gameTitle)
                      // stackView.push("qrc:/gui/GameLaunchView.qml", { gameId: model.gameId })
                  }
              }
             focus: true
             Keys.onReturnPressed: {
                 console.log("Launched game:", gameTitle)
                 // stackView.push("qrc:/gui/GameLaunchView.qml", { gameId: model.gameId })
             }
         }
    }

    Component.onCompleted: {
        if (typeof mainToolBar !== 'undefined') mainToolBar.visible = true
        if (typeof settingsButton !== 'undefined') settingsButton.visible = true
        if (typeof topMenu !== 'undefined') topMenu.visible = true
    }
}