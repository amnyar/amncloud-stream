import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: dashboardRoot
    objectName: "Dashboard"
    anchors.fill: parent
    implicitHeight: 600
    implicitWidth: 1000

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
                        source: "qrc:/placeholder_logo.png"
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40
                        fillMode: Image.PreserveAspectFit
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        id: searchBtn
                        icon.source: "qrc:/placeholder_search_icon.png"
                        icon.color: "white"
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignVCenter
                        flat: true
                    }
                    Button {
                        id: notificationBtn
                        icon.source: "qrc:/placeholder_notif_icon.png"
                        icon.color: "white"
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignVCenter
                        flat: true
                    }
                     Button {
                         id: profileBtn
                         icon.source: "qrc:/placeholder_avatar.png"
                         Layout.preferredWidth: 40
                         Layout.preferredHeight: 40
                         Layout.alignment: Qt.AlignVCenter
                         flat: true
                         onClicked: {
                         stackView.push("qrc:/gui/Profile.qml")
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
                    source: "qrc:/no_mans_sky_banner.png"
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
                         text: "NO MAN'S SKY"
                         font.pixelSize: 36
                         font.bold: true
                         color: "white"
                         font.family: defaultFont
                     }
                     Text {
                         text: "Build for an epic journey."
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

                    Image { source: "qrc:/placeholder_calendar.png"; width: 24; height: 24; fillMode: Image.PreserveAspectFit; color: "white" }
                    Image { source: "qrc:/placeholder_controller.png"; width: 24; height: 24; fillMode: Image.PreserveAspectFit; color: "white" }
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
                    background: Rectangle {
                        color: "#333333"
                        radius: 15
                        border.color: "#555555"
                        border.width: 1
                    }
                    contentItem: Text {
                       text: allGamesBtn.text
                       font: allGamesBtn.font
                       color: "white"
                       horizontalAlignment: Text.AlignHCenter
                       verticalAlignment: Text.AlignVCenter
                    }
                    padding: 10
                    leftPadding: 20
                    rightPadding: 20
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
                           onClicked: {
                                if (gameListView.currentIndex > 0) {
                                     gameListView.decrementCurrentIndex()
                                }
                           }
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
                           onClicked: {
                                if (gameListView.currentIndex < gameListView.count - 1) {
                                    gameListView.incrementCurrentIndex()
                                }
                           }
                            enabled: gameListView.currentIndex < gameListView.count - 1
                       }
                 }
             }
        }
    }

    ListModel {
         id: gameListModel
         ListElement { gameTitle: "No Man's Sky"; posterUrl: "qrc:/placeholder_poster_nms.png" }
         ListElement { gameTitle: "Ghost Recon"; posterUrl: "qrc:/placeholder_poster_gr.png" }
         ListElement { gameTitle: "Age of Mythology"; posterUrl: "qrc:/placeholder_poster_aom.png" }
         ListElement { gameTitle: "Death's Door"; posterUrl: "qrc:/placeholder_poster_dd.png" }
         ListElement { gameTitle: "Far Cry 6"; posterUrl: "qrc:/placeholder_poster_fc6.png" }
         ListElement { gameTitle: "Resident Evil 8"; posterUrl: "qrc:/placeholder_poster_re8.png" }
         ListElement { gameTitle: "Days Gone"; posterUrl: "qrc:/placeholder_poster_dg.png" }
         ListElement { gameTitle: "Another Game"; posterUrl: "qrc:/placeholder_poster_ag.png" }
         ListElement { gameTitle: "Game 9"; posterUrl: "qrc:/placeholder_poster_g9.png" }
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