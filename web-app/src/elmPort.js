function sendToElm(value) {
    alert(value);
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