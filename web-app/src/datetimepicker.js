$("#basicDate").flatpickr({
    enableTime: true,
    dateFormat: "d-m-Y H:i"
});

$("#rangeDate").flatpickr({
        mode: 'range',
        dateFormat: "d-m-Y"
});

$("#timePicker").flatpickr({
        enableTime: true,
        noCalendar: true,
        time_24hr: true,
        dateFormat: "H:i",
});

$(".resetDate").flatpickr({
        wrap: true,
        weekNumbers: true,
});