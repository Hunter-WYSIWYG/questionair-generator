var app = Elm.Main.init({
    node: document.getElementById('elm')
});

app.ports.enterUpload.subscribe(function() {
    //Hide footer if the user wants to upload a questionnaire
    var footer = document.getElementById('footer');
    footer.style.display = 'none';
});

app.ports.leaveUpload.subscribe(function() {
    //Show footer if the user wants to edit a questionnaire
    var footer = document.getElementById('footer');
    footer.style.display = 'block';
});

app.ports.decodedViewingTime.subscribe(function(time) {
    var input = document.getElementById("rangeDate");
    input.value = time;
});

app.ports.decodedReminderTime.subscribe(function(time) {
    var input = document.getElementById("basicDate");
    input.value = time;
});

app.ports.decodedEditTime.subscribe(function(time) {
    var input = document.getElementById("timePicker");
    input.value = time;
});

function appendToTimesTable() {
    var table = document.getElementById("reminderTimesTable").getElementsByTagName('tbody')[0];

    if (!document.getElementById("täglich").checked 
        && !document.getElementById("wöchentlich").checked 
        && !document.getElementById("monatlich").checked) {
            
        var row = table.insertRow(-1);
        var time = row.insertCell(0);;
        time.innerHTML = document.getElementById("basicDate").value;
        return;

    } else if (document.getElementById('rangeDate').value == '') {
        alert("Es wurde keine Erscheinungszeit gesetzt. Bitte wählen Sie erst eine Erscheinungszeit!")
        return;
    } 

    var inputString = document.getElementById("rangeDate").value;
    var parts = inputString.split(' ');
    var begin = parseDateTime(document.getElementById("basicDate").value);
    var end = parseDate(parts[2]);
    
    for (var i = 0; begin <= end; i++) {
        var row = table.insertRow(-1);
        var time = row.insertCell(0);
        time.innerHTML = begin;

        if (document.getElementById("täglich").checked) {
            begin = addDay(begin);
        } else if (document.getElementById("wöchentlich").checked) {
            begin = addWeek(begin);
        } else if (document.getElementById("monatlich").checked) {
            begin = addMonth(begin);
        }

    }

    document.getElementById("reminderTimesForm").reset();
}

function parseDate(date) {
    var parts = date.split('-');
    return new Date(parts[2], parts[1]-1, parts[0]);
}

function parseDateTime(dateTime) {
    var parts = dateTime.split(' ');
    var dateParts = parts[0].split('-');
    var timeParts = parts[1].split(':');

    return new Date(dateParts[2], dateParts[1]-1, dateParts[0], timeParts[0], timeParts[1]);
}

function addDay(date) {
    return new Date(date.setDate(date.getDate() + 1));      
}

function addWeek(date) {
    return new Date(date.setDate(date.getDate() + 7));      
}

function addMonth(date) {
    return new Date(date.setMonth(date.getMonth() + 1));      
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
        //resetTimesTable();
    }

    if (value == "editTime") {
        var modal = document.getElementById("modalEditTime");
        modal.classList.remove("is-active");
    }
}