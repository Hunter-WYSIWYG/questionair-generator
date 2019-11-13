var app = Elm.Main.init({
    node: document.getElementById('elm')
  });

function appendToTimesTable() {
    var table = document.getElementById("reminderTimesTable").getElementsByTagName('tbody')[0];
    var row = table.insertRow(0);
    var time = row.insertCell(0);
    var repeat = row.insertCell(1);
    time.innerHTML = document.getElementById("basicDate").value;

    var repeatValue = " Keine";

    if (document.getElementById("täglich").checked) {
        repeatValue = " täglich";
    } else if (document.getElementById("wöchentlich").checked) {
        repeatValue = " wöchentlich";
    } else if (document.getElementById("monatlich").checked) {
        repeatValue = " monatlich";
    }

    repeat.innerHTML = repeatValue;
    document.getElementById("reminderTimesForm").reset();
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

    sendToElm(allTimes, "reminderTimes")
}

function sendToElm(value, dateTimePicker) {

    if (dateTimePicker == "viewingTime") {
        app.ports.viewingTime.send(value);
    }

    if (dateTimePicker == "reminderTimes") {
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

    if (value == "reminderTimes") {
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

    if (value == "reminderTimes") {
        var modal = document.getElementById("modalReminderTime");
        modal.classList.remove("is-active");
        connectReminderTimes();
        resetTimesTable();
    }

    if (value == "editTime") {
        var modal = document.getElementById("modalEditTime");
        modal.classList.remove("is-active");
    }
}