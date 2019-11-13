var app = Elm.Main.init({
    node: document.getElementById('elm')
  });

function appendToTimesTable() {
    var table = document.getElementById("reminderTimesTable").getElementsByTagName('tbody')[0];
    var row = table.insertRow(0);
    var cell = row.insertCell(0);
    var value = document.getElementById("basicDate").value;
    cell.innerHTML = value;
}

function resetTimesTable() {
    var table = document.getElementById("reminderTimesTable").getElementsByTagName('tbody')[0];
    table.innerHTML = "";
}

function connectReminderTimes() {
    var table = document.getElementById("reminderTimesTable").getElementsByTagName('tbody')[0];
    var allTimes;

    if (table.rows.length > 0) {
        allTimes = table.rows[0].innerText;
    }

    for (var i = 1; i < table.rows.length; i++) {
        allTimes += ';' + table.rows[i].innerText;
    }

    sendToElm(allTimes, "reminderTime");
}

function sendToElm(value, dateTimePicker) {

    if (dateTimePicker == "viewingTime") {
        app.ports.viewingTime.send(value);
    }

    if (dateTimePicker == "reminderTime") {
        app.ports.reminderTime.send(value);
    }

    if (dateTimePicker == "editTime") {
        app.ports.editTime.send(value);
    }
}

function openDTPModal(value) {
    
    if (value == "viewingTime") {
        var modal = document.getElementById("modalViewingTime");
        modal.classList.add("is-active");
    }

    if (value == "reminderTime") {
        var modal = document.getElementById("modalReminderTime");
        modal.classList.add("is-active");
    }

    if (value == "editTime") {
        var modal = document.getElementById("modalEditTime");
        modal.classList.add("is-active");
    }
}

function closeDTPModal(value) {

    if (value == 'viewingTime') {
        var modal = document.getElementById("modalViewingTime");
        modal.classList.remove("is-active");
    }

    if (value == "reminderTime") {
        var modal = document.getElementById("modalReminderTime");
        modal.classList.remove("is-active");
        connectReminderTimes();
    }

    if (value == "editTime") {
        var modal = document.getElementById("modalEditTime");
        modal.classList.remove("is-active");
    }
}