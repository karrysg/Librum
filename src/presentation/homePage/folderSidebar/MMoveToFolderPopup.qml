import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import CustomComponents
import Librum.controllers
import Librum.style
import Librum.icons
import Librum.fonts

Popup {
    id: root
    // We can either move a book or a folder to some folder
    property string bookUuid
    property string folderUuid

    implicitWidth: 400
    implicitHeight: layout.implicitHeight + 28
    horizontalPadding: 24
    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
    background: Rectangle {
        color: Style.colorPopupBackground
        border.width: 1
        border.color: Style.colorContainerBorder
        radius: 6
        antialiasing: true
    }

    onOpened: root.forceActiveFocus()

    ColumnLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        RowLayout {
            id: headerRow
            Layout.preferredWidth: parent.width
            Layout.topMargin: 12

            Label {
                id: popupTitle
                Layout.alignment: Qt.AlignLeft
                text: qsTr("Move to")
                font.weight: Font.Medium
                font.pointSize: Fonts.size16
                color: Style.colorTitle
            }

            MButton {
                id: closeButton
                Layout.preferredHeight: 32
                Layout.preferredWidth: 32
                Layout.alignment: Qt.AlignRight
                backgroundColor: "transparent"
                opacityOnPressed: 0.7
                borderColor: "transparent"
                radius: 6
                borderColorOnPressed: Style.colorButtonBorder
                imagePath: Icons.closePopup
                imageSize: 14

                onClicked: root.close()
            }
        }

        Rectangle {
            Layout.topMargin: 4
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 1
            color: Style.colorSeparator
        }

        ScrollView {
            id: scrollBar
            property bool isEnabled: contentHeight > height

            Layout.topMargin: 16
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(implicitHeight, 480)
            Layout.minimumHeight: 180

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            onIsEnabledChanged: {
                if (isEnabled)
                    ScrollBar.vertical.policy = ScrollBar.AlwaysOn
                else
                    ScrollBar.vertical.policy = ScrollBar.AlwaysOff
            }

            TreeView {
                id: treeView
                property int indent: 18

                anchors.fill: parent
                anchors.margins: 1
                anchors.rightMargin: scrollBar.isEnabled ? 12 : 0
                reuseItems: false
                clip: true
                focus: true

                model: FolderController.foldersModel
                delegate: Pane {
                    id: treeNode
                    required property string name
                    required property string uuid
                    required property TreeView treeView
                    required property bool expanded
                    required property int hasChildren
                    required property int depth

                    implicitWidth: treeView.width
                    width: implicitWidth
                    implicitHeight: 32
                    padding: 0

                    Component.onCompleted: treeView.expand(row)

                    background: Rectangle {
                        anchors.fill: parent
                        color: backgroundArea.containsMouse
                               || internal.selectedFolder
                               === treeNode.uuid ? "white" : "transparent"
                        opacity: 0.08
                        radius: 4
                    }

                    RowLayout {
                        id: nodeLayout
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0

                        Image {
                            id: indicator
                            Layout.preferredWidth: implicitWidth
                            Layout.leftMargin: treeNode.depth * treeView.indent + 2
                            Layout.alignment: Qt.AlignVCenter
                            visible: treeNode.hasChildren
                            opacity: backgroundArea.pressed ? 0.7 : 1
                            source: Icons.arrowheadNextIcon
                            sourceSize.width: 22
                            fillMode: Image.PreserveAspectFit
                            rotation: treeNode.expanded ? 90 : 0
                        }

                        Image {
                            id: icon
                            Layout.preferredWidth: implicitWidth
                            Layout.leftMargin: treeNode.hasChildren ? indicator.width * 0.1 : indicator.width * 1.1 + depth * treeView.indent + 2
                            Layout.alignment: Qt.AlignVCenter
                            opacity: backgroundArea.pressed ? 0.7 : 1
                            source: Icons.folder
                            sourceSize.width: 17
                            fillMode: Image.PreserveAspectFit
                        }

                        Label {
                            id: treeNodeLabel
                            Layout.fillWidth: true
                            // To have a bigger clickable area
                            Layout.preferredHeight: treeNode.height
                            Layout.leftMargin: 6
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            topPadding: 1
                            clip: true
                            color: Style.colorText
                            opacity: backgroundArea.pressed ? 0.7 : 1
                            font.pointSize: Fonts.size10dot25
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                            text: treeNode.name
                        }
                    }

                    MouseArea {
                        id: backgroundArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: internal.selectedFolder = treeNode.uuid
                            onDoubleClicked: {
                                internal.selectedFolder = treeNode.uuid

                                if (internal.selectedFolder !== root.folderUuid)
                                    internal.moveFolder()

                                root.close()
                            }
                        }
                    }
                }
            }

            Component.onCompleted: {
                // contentItem is the TreeView's underlying Flickable
                contentItem.flickDeceleration = 10000
                contentItem.maximumFlickVelocity = 2000
                contentItem.boundsBehavior = Flickable.StopAtBounds
                contentItem.boundsMovement = Flickable.StopAtBounds
                contentItem.flickableDirection = Flickable.VerticalFlick

                contentItem.interactive = Qt.binding(function () {
                    return scrollBar.isEnabled
                })
            }
        }

        RowLayout {
            Layout.preferredWidth: parent.width
            Layout.topMargin: 26
            height: cancelButton.height
            spacing: 12

            MButton {
                id: cancelButton
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                borderWidth: 1
                backgroundColor: "transparent"
                fontSize: Fonts.size10dot5
                opacityOnPressed: 0.85
                textColor: Style.colorText
                fontWeight: Font.Medium
                text: qsTr("Cancel")

                onClicked: root.close()
            }

            MButton {
                id: selectButton
                property bool enabled: internal.selectedFolder !== ""
                                       && internal.selectedFolder !== root.folderUuid

                Layout.fillWidth: true
                Layout.preferredHeight: 34
                borderWidth: 0
                backgroundColor: Style.colorBasePurple
                opacity: enabled ? 1 : 0.4
                fontSize: Fonts.size10dot5
                opacityOnPressed: 0.85
                textColor: Style.colorFocusedButtonText
                fontWeight: Font.Medium
                text: qsTr("Select")

                onClicked: {
                    if (!enabled)
                        return

                    internal.moveFolder()
                    root.close()
                }
            }
        }
    }

    QtObject {
        id: internal
        property string selectedFolder

        function moveFolder() {
            if (selectedFolder === "" || selectedFolder === root.folderUuid)
                return

            let success = FolderController.moveFolder(root.folderUuid,
                                                      selectedFolder)
            if (!success)
                print("Failed")
        }
    }
}
