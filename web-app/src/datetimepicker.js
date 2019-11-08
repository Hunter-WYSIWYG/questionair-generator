$("#basicDate").flatpickr({
    mode: "multiple",
    enableTime: true,
    dateFormat: "F, d Y H:i"
});

$("#rangeDate").flatpickr({
        mode: 'range',
        dateFormat: "Y-m-d"
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