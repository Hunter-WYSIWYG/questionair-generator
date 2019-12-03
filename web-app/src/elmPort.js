//Initiates our Elm App
var app = Elm.Main.init({
    node: document.getElementById('elm')
});

//Hide footer if the user wants to upload a questionnaire
app.ports.enterUpload.subscribe(function() {
    var footer = document.getElementById('footer');
    footer.style.display = 'none';
});

//Show footer if the user wants to edit a questionnaire
app.ports.leaveUpload.subscribe(function() {
    var footer = document.getElementById('footer');
    footer.style.display = 'block';
});

//Listens to the Elm App and sets up the times if the user uploads a questionnaire
app.ports.decodedViewingTime.subscribe(function(time) {
    var input = document.getElementById("rangeDate");
    input.value = time;
});

app.ports.decodedReminderTime.subscribe(function(time) {
    var list = time;
    var table = document.getElementById("reminderTimesTable").getElementsByTagName('tbody')[0];

    for (var i = 0; i < list.length; i++) {
        var row = table.insertRow(-1);
        var time = row.insertCell(0);
        time.innerHTML = dateToEuropeanTime(new Date(list[i]));
    }
});

app.ports.decodedEditTime.subscribe(function(time) {
    var input = document.getElementById("timePicker");
    input.value = time;
});

//Adds the given reminder time to the table of reminder times inside a modal
function appendToTimesTable() {
    var table = document.getElementById("reminderTimesTable").getElementsByTagName('tbody')[0];

    if (!document.getElementById("stündlichTag").checked 
        && !document.getElementById("stündlichGesamt").checked 
        && !document.getElementById("täglich").checked 
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

    if (document.getElementById("stündlichTag").checked) {
        var end = new Date(begin.getTime());;
        end.setHours(23,59,59);
        console.log("begin:", begin);
        console.log("end:", end);
    } else {
        var end = parseDate(parts[2]);
    }
    
    for (var i = 0; begin <= end; i++) {
        var row = table.insertRow(-1);
        var time = row.insertCell(0);
        time.innerHTML = dateToEuropeanTime(begin);

        if (document.getElementById("stündlichGesamt").checked || document.getElementById("stündlichTag").checked) {
            begin = addHour(begin);
        } else if (document.getElementById("täglich").checked) {
            begin = addDay(begin);
        } else if (document.getElementById("wöchentlich").checked) {
            begin = addWeek(begin);
        } else if (document.getElementById("monatlich").checked) {
            begin = addMonth(begin);
        }

    }

    document.getElementById("reminderTimesForm").reset();
}

//Parses a date like dd-mm-YYYY to a JavaScript date
function parseDate(date) {
    var parts = date.split('-');
    return new Date(parts[2], parts[1]-1, parts[0]);
}

//Parses a date like dd-mm-YYY hh-mm to a JavaScript date
function parseDateTime(dateTime) {
    var parts = dateTime.split(' ');
    var dateParts = parts[0].split('-');
    var timeParts = parts[1].split(':');

    return new Date(dateParts[2], dateParts[1]-1, dateParts[0], timeParts[0], timeParts[1]);
}

//Converts a Date to the European date time format
function dateToEuropeanTime(dateTime) {
    var year = dateTime.getFullYear();
    var month = dateTime.getMonth() + 1;
    
    if (month < 10) {
        month = '0' + month;
    }

    var day = dateTime.getDate();

    if (day < 10) {
        day = '0' + day;
    }

    var hour = dateTime.getHours();

    if (hour < 10) {
        hour = '0' + hour;
    }

    var minutes = dateTime.getMinutes();

    if (minutes < 10) {
        minutes = '0' + minutes;
    }

    return day + '-' + month + '-' + year + ' ' + hour + ':' + minutes;
}

//Converts a Date to a JSON string
function europeanDateToJson(dateTime) {
    var parts = dateTime.split(' ');
    var dateParts = parts[0].split('-');
    var timeParts = parts[1].split(':');

    var day = dateParts[0];
    var month = dateParts[1];
    var year = dateParts[2];
    var hour = timeParts[0];
    var minute = timeParts[1];

    return year + '-' + month + '-' + day + 'T' + hour + ':' + minute + ':00+01:00';
}

//Adds a hour to a given date
function addHour(date) {
    return new Date(date.setHours(date.getHours() + 1))
}

//Adds a day to a given date
function addDay(date) {
    return new Date(date.setDate(date.getDate() + 1));      
}

//Adds a week to a given date
function addWeek(date) {
    return new Date(date.setDate(date.getDate() + 7));      
}

//Adds a month to a given date
function addMonth(date) {
    return new Date(date.setMonth(date.getMonth() + 1));      
}

//Resets the table with the reminder times
function resetTimesTable() {
    var table = document.getElementById("reminderTimesTable").getElementsByTagName('tbody')[0];
    table.innerHTML = "";
}

//Reads the table with the reminder times an sends the array to the Elm app
function connectReminderTimes() {
    var table = document.getElementById("reminderTimesTable").getElementsByTagName('tbody')[0];
    var list = [];

    for (var i = 0; i < table.rows.length; i++) {
        list.push(europeanDateToJson(table.rows[i].innerText));
    }

    sendToElm(list, "reminderTimes");
}

//Sends the given values of the given dateTimePicker to the Elm app
function sendToElm(value, dateTimePicker) {

    if (dateTimePicker == "viewingTime") {
        var parts = value.split(" ");
        var newFormat = parts[0] + ";" + parts[2];
        app.ports.viewingTime.send(newFormat);
    }

    if (dateTimePicker == "reminderTimes") {
        app.ports.reminderTime.send(value);
    }

    if (dateTimePicker == "editTime") {
        app.ports.editTime.send(value);
    }
}

//Opens a modal for the given time type
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

//Closes a modal for the given time type
function closeDTPModal(value) {

    if (value == 'viewingTime') {
        var modal = document.getElementById("modalViewingTime");
        modal.classList.remove("is-active");
    }

    if (value == "reminderTimes") {
        var modal = document.getElementById("modalReminderTime");
        modal.classList.remove("is-active");
        connectReminderTimes();
    }

    if (value == "editTime") {
        var modal = document.getElementById("modalEditTime");
        modal.classList.remove("is-active");
    }
}