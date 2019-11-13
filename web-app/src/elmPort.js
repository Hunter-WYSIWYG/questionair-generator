var app = Elm.Main.init({
    node: document.getElementById('elm')
  });

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
    }

    if (value == "editTime") {
        var modal = document.getElementById("modalEditTime");
        modal.classList.remove("is-active");
    }
}