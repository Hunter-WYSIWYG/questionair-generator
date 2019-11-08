function sendToElm(value) {
    alert(value);
}

function openDTPModal(value) {
    
    if (value == 1) {
        var modal = document.getElementById("modalDTP1");
        modal.classList.add("is-active");
    }
}

function closeDTPModal(value) {

    if (value == 1) {
        var modal = document.getElementById("modalDTP1");
        modal.classList.remove("is-active");
    }
}