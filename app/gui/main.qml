import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls.Material 2.2

import ComputerManager 1.0
import AutoUpdateChecker 1.0
import StreamingPreferences 1.0
import SystemProperties 1.0
import SdlGamepadKeyNavigation 1.0

ApplicationWindow {
    id: mainRoot // Added ID for referencing from Connections

    property string defaultFont: iranFont.name

    FontLoader {
        id: iranFont
        source: "qrc:/fonts/IRANSans.ttf"
    }

    property bool pollingActive: false
    property bool clearOnBack: false

    width: 1280
    height: 600
    title: "Bazi Cloud"
    visible: true // Make sure window is initially visible

    function doEarlyInit() {
        if (SystemProperties.usesMaterial3Theme) { Material.background = "#303030" }
        SdlGamepadKeyNavigation.enable()
    }

    Component.onCompleted: {
        if (SystemProperties.hasDesktopEnvironment) {
            if (StreamingPreferences.uiDisplayMode == StreamingPreferences.UI_MAXIMIZED) { mainRoot.showMaximized() }
            else if (StreamingPreferences.uiDisplayMode == StreamingPreferences.UI_FULLSCREEN) { mainRoot.showFullScreen() }
            else { mainRoot.show() }
        } else { mainRoot.showFullScreen() }

        if (SystemProperties.isWow64) { wow64Dialog.open() }
        else if (!SystemProperties.hasHardwareAcceleration && StreamingPreferences.videoDecoderSelection !== StreamingPreferences.VDS_FORCE_SOFTWARE) {
            if (SystemProperties.isRunningXWayland) { xWaylandDialog.open() }
            else { noHwDecoderDialog.open() }
        }
        if (SystemProperties.unmappedGamepads) {
            unmappedGamepadDialog.unmappedGamepads = SystemProperties.unmappedGamepads
            unmappedGamepadDialog.open()
        }
    }

    Text { id: tooltipTextLayoutHelper; visible: false; font: ToolTip.toolTip.font; text: ToolTip.toolTip.text }
    ToolTip.toolTip.contentWidth: Math.min(tooltipTextLayoutHelper.width, 400)

    function goBack() {
        if (clearOnBack) { stackView.pop(null); clearOnBack = false }
        else { stackView.pop() }
    }

    function handleLoginSuccess() {
        console.log("Login/Registration Success signal received. Navigating to Dashboard.")
        stackView.clear()
        stackView.push("qrc:/gui/Dashboard.qml")
    }

    function handleNeedsSignup(phoneNum) {
        console.log("Needs Signup signal received for:", phoneNum)
        // Push Signup using simple form, Connections will handle its signal
        stackView.push("qrc:/gui/Signup.qml", { initialPhone: phoneNum })
    }

    StackView {
        id: stackView
        anchors.fill: parent
        focus: true

        Component.onCompleted: {
             doEarlyInit()
             stackView.clear()
             // Use simple push for the initial item
             stackView.push("qrc:/gui/LoginWithPhone.qml")
        }

        // Handle signals from the CURRENT item on the stack
        Connections {
             target: stackView.currentItem
             ignoreUnknownSignals: true // Important to avoid warnings if item doesn't have the signal

             function onLoginSuccess() {
                 // Check if the signal came from an expected component (optional but safer)
                 // if (mainRoot.qmltypeof(target, "VerifyCode") || mainRoot.qmltypeof(target, "LoginWithPhone")) {
                     mainRoot.handleLoginSuccess()
                 // }
             }

             function onNeedsSignup(phoneNum) {
                 // if (mainRoot.qmltypeof(target, "LoginWithPhone")) {
                     mainRoot.handleNeedsSignup(phoneNum)
                 // }
             }

             function onRegistrationSuccess() {
                 // if (mainRoot.qmltypeof(target, "Signup")) {
                     mainRoot.handleLoginSuccess() // Reuse login success handler
                 // }
             }
        }


        onCurrentItemChanged: { if (currentItem) { currentItem.forceActiveFocus() } }
        Keys.onEscapePressed: { if (depth > 1) { goBack() } else { quitConfirmationDialog.open() } }
        Keys.onBackPressed: { if (depth > 1) { goBack() } else { quitConfirmationDialog.open() } }
        Keys.onMenuPressed: { if (settingsButton && settingsButton.visible) settingsButton.clicked() }
        Keys.onHangupPressed: { if (settingsButton && settingsButton.visible) settingsButton.clicked() }
    }

    Timer {
        id: inactivityTimer
        interval: 5 * 60000
        onTriggered: { if (!active && pollingActive) { ComputerManager.stopPollingAsync(); pollingActive = false } }
    }

    onVisibleChanged: {
        if (!visible) { inactivityTimer.stop(); if (pollingActive) { ComputerManager.stopPollingAsync(); pollingActive = false } }
        else if (active) { inactivityTimer.stop(); if (!pollingActive) { ComputerManager.startPolling(); pollingActive = true } }
        SdlGamepadKeyNavigation.notifyWindowFocus(visible && active)
    }
    onActiveChanged: {
        if (active) { inactivityTimer.stop(); if (!pollingActive) { ComputerManager.startPolling(); pollingActive = true } }
        else { inactivityTimer.restart() }
        SdlGamepadKeyNavigation.notifyWindowFocus(visible && active)
    }

    function qmltypeof(obj, className) { if (!obj) { return false } var str = obj.toString(); return str.startsWith(className + "(") || str.startsWith(className + "_QML") }
    function navigateTo(url, objectType) { var existingItem = stackView.find(function(item, index) { return qmltypeof(item, objectType) }); if (existingItem !== null) { stackView.pop(existingItem) } else { stackView.push(url) } }

    header: ToolBar { /* ... Toolbar code remains the same ... */
        id: toolBar
        height: 60; anchors.topMargin: 5; anchors.bottomMargin: 5
        Label { id: titleLabel; visible: toolBar.width > 700; anchors.fill: parent; text: "Bazi Cloud"; font.pointSize: 20; elide: Label.ElideRight; horizontalAlignment: Qt.AlignHCenter; verticalAlignment: Qt.AlignVCenter; font.family: defaultFont }
        RowLayout {
            spacing: 10; anchors.leftMargin: 10; anchors.rightMargin: 10; anchors.fill: parent
            NavigableToolButton { id: backNavButton; visible: stackView.depth > 1; iconSource: "qrc:/res/arrow_left.svg"; onClicked: goBack; Keys.onDownPressed: { if (stackView.currentItem) stackView.currentItem.forceActiveFocus(Qt.TabFocus) } }
            Label { id: titleRowLabel; font.pointSize: titleLabel.font.pointSize; elide: Label.ElideRight; horizontalAlignment: Qt.AlignHCenter; verticalAlignment: Qt.AlignVCenter; Layout.fillWidth: true; font.family: defaultFont; text: !titleLabel.visible ? "Bazi Cloud" : "" }
            Label { id: versionLabel; visible: stackView.currentItem ? qmltypeof(stackView.currentItem, "SettingsView") : false; text: qsTr("Version %1").arg(SystemProperties.versionString); font.pointSize: 12; horizontalAlignment: Qt.AlignRight; verticalAlignment: Qt.AlignVCenter; font.family: defaultFont }
            NavigableToolButton { id: discordButton; visible: SystemProperties.hasBrowser && (stackView.currentItem ? qmltypeof(stackView.currentItem, "SettingsView") : false); iconSource: "qrc:/res/discord.svg"; ToolTip.delay: 1000; ToolTip.timeout: 3000; ToolTip.visible: hovered; ToolTip.text: qsTr("Join our community on Discord"); onClicked: Qt.openUrlExternally("https://moonlight-stream.org/discord"); Keys.onDownPressed: { if (stackView.currentItem) stackView.currentItem.forceActiveFocus(Qt.TabFocus) } }
            NavigableToolButton { id: addPcButton; visible: stackView.currentItem ? qmltypeof(stackView.currentItem, "PcView") : false; iconSource:  "qrc:/res/ic_add_to_queue_white_48px.svg"; ToolTip.delay: 1000; ToolTip.timeout: 3000; ToolTip.visible: hovered; ToolTip.text: qsTr("Add PC manually") + (newPcShortcut.nativeText ? (" ("+newPcShortcut.nativeText+")") : ""); Shortcut { id: newPcShortcut; sequence: StandardKey.New; onActivated: addPcButton.clicked() }; onClicked: { addPcDialog.open() }; Keys.onDownPressed: { if (stackView.currentItem) stackView.currentItem.forceActiveFocus(Qt.TabFocus) } }
            NavigableToolButton { property string browserUrl: ""; id: updateButton; iconSource: "qrc:/res/update.svg"; ToolTip.delay: 1000; ToolTip.timeout: 3000; ToolTip.visible: hovered || visible; visible: false; onClicked: { if (SystemProperties.hasBrowser) { Qt.openUrlExternally(browserUrl) } }; function updateAvailable(version, url) { ToolTip.text = qsTr("Update available for Moonlight: Version %1").arg(version); updateButton.browserUrl = url; updateButton.visible = true }; Component.onCompleted: { AutoUpdateChecker.onUpdateAvailable.connect(updateAvailable); AutoUpdateChecker.start() }; Keys.onDownPressed: { if (stackView.currentItem) stackView.currentItem.forceActiveFocus(Qt.TabFocus) } }
            NavigableToolButton { id: helpButton; visible: SystemProperties.hasBrowser; iconSource: "qrc:/res/question_mark.svg"; ToolTip.delay: 1000; ToolTip.timeout: 3000; ToolTip.visible: hovered; ToolTip.text: qsTr("Help") + (helpShortcut.nativeText ? (" ("+helpShortcut.nativeText+")") : ""); Shortcut { id: helpShortcut; sequence: StandardKey.HelpContents; onActivated: helpButton.clicked() }; onClicked: Qt.openUrlExternally("https://github.com/moonlight-stream/moonlight-docs/wiki/Setup-Guide"); Keys.onDownPressed: { if (stackView.currentItem) stackView.currentItem.forceActiveFocus(Qt.TabFocus) } }
            NavigableToolButton { visible: false; ToolTip.delay: 1000; ToolTip.timeout: 3000; ToolTip.visible: hovered; ToolTip.text: qsTr("Gamepad Mapper"); iconSource: "qrc:/res/ic_videogame_asset_white_48px.svg"; onClicked: navigateTo("qrc:/gui/GamepadMapper.qml", "GamepadMapper"); Keys.onDownPressed: { if (stackView.currentItem) stackView.currentItem.forceActiveFocus(Qt.TabFocus) } }
            NavigableToolButton { id: settingsButton; iconSource:  "qrc:/res/settings.svg"; onClicked: navigateTo("qrc:/gui/SettingsView.qml", "SettingsView"); Keys.onDownPressed: { if (stackView.currentItem) stackView.currentItem.forceActiveFocus(Qt.TabFocus) }; Shortcut { id: settingsShortcut; sequence: StandardKey.Preferences; onActivated: settingsButton.clicked() }; ToolTip.delay: 1000; ToolTip.timeout: 3000; ToolTip.visible: hovered; ToolTip.text: qsTr("Settings") + (settingsShortcut.nativeText ? (" ("+settingsShortcut.nativeText+")") : "") }
        }
    }

    // Dialog definitions remain the same
    ErrorMessageDialog { id: noHwDecoderDialog; text: qsTr("No functioning hardware accelerated video decoder..."); helpText: qsTr("Click the Help button..."); helpUrl: "..." }
    ErrorMessageDialog { id: xWaylandDialog; text: qsTr("Hardware acceleration doesn't work on XWayland..."); helpText: qsTr("Click the Help button..."); helpUrl: "..." }
    NavigableMessageDialog { id: wow64Dialog; standardButtons: Dialog.Ok | Dialog.Cancel; text: qsTr("This version of Moonlight isn't optimized..."); onAccepted: { Qt.openUrlExternally("...") } }
    ErrorMessageDialog { id: unmappedGamepadDialog; property string unmappedGamepads : ""; text: qsTr("Moonlight detected gamepads without a mapping:") + "\n" + unmappedGamepads; helpTextSeparator: "\n\n"; helpText: qsTr("Click the Help button..."); helpUrl: "..." }
    NavigableMessageDialog { id: quitConfirmationDialog; standardButtons: Dialog.Yes | Dialog.No; text: qsTr("Are you sure you want to quit?"); onAccepted: Qt.quit() }
    ErrorMessageDialog { id: streamSegueErrorDialog; property bool quitAfter: false; onClosed: { if (quitAfter) { Qt.quit() } text = "" } }
    NavigableDialog {
        id: addPcDialog; property string label: qsTr("Enter the IP address..."); standardButtons: Dialog.Ok | Dialog.Cancel; onOpened: { editText.forceActiveFocus() }; onClosed: { editText.clear() }; onAccepted: { if (editText.text) { ComputerManager.addNewHostManually(editText.text.trim()) } }
        ColumnLayout { Label { text: addPcDialog.label; font.bold: true; font.family: defaultFont }; TextField { id: editText; Layout.fillWidth: true; focus: true; font.family: defaultFont; Keys.onReturnPressed: { addPcDialog.accept() }; Keys.onEnterPressed: { addPcDialog.accept() } } }
    }
}