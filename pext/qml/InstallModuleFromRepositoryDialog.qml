/*
    Copyright (c) 2016 - 2017 Sylvia van Os <sylvia@hackerchick.me>

    This file is part of Pext

    Pext is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0

Dialog {
    title: "Pext"
    standardButtons: StandardButton.Ok | StandardButton.Cancel

    property var applicationWindow
    property var installRequest
    property var repositories

    ColumnLayout {
        Label {
            text: "Where do you want to get modules from?"
        }

        ComboBox {
            id: combobox
            model: repositories.map(function(repository) { return repository.name; })
            Layout.fillWidth: true
        }
    }

    Component.onCompleted: {
        visible = true;
        combobox.focus = true;
    }

    function getModules(url, callback) {
        var xmlhttp = new XMLHttpRequest();

        xmlhttp.onreadystatechange = function() {
            if (xmlhttp.readyState == XMLHttpRequest.DONE && xmlhttp.status == 200) {
                callback(xmlhttp.response);
            }
        }

        xmlhttp.open("GET", url, true);
        xmlhttp.send();
    }

    onAccepted: {
        getModules(repositories[combobox.currentIndex].url, function(response) {
            var modules = JSON.parse(response).modules;
            if (modules.length == 0) {
                var installModuleFromRepositoryNoModulesAvailableDialog = Qt.createComponent("InstallModuleFromRepositoryNoModulesAvailableDialog.qml");
                installModuleFromRepositoryNoModulesAvailableDialog.createObject(applicationWindow);
            } else {
                var installModuleFromRepositorySelectModuleDialog = Qt.createComponent("InstallModuleFromRepositorySelectModuleDialog.qml");
                installModuleFromRepositorySelectModuleDialog.createObject(applicationWindow,
                    {"installRequest": installRequest,
                     "modules": modules});
            };
        });
    }
}

