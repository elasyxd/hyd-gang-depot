




let currentPin = "";
const maxPinLength = 6;

function updateSlots() {
  const slots = document.querySelectorAll('.pin-slot');
  slots.forEach((slot, index) => {
    if (index < currentPin.length) {
      slot.classList.add('filled');
      slot.classList.remove('active');
    } else if (index === currentPin.length) {
      slot.classList.add('active');
      slot.classList.remove('filled');
    } else {
      slot.classList.remove('filled', 'active');
    }
  });

  // Onayla butonu durumunu güncelle
  const confirmBtn = document.querySelector('.confirm-btn');
  if (currentPin.length === maxPinLength) {
    confirmBtn.classList.add('active');
  } else {
    confirmBtn.classList.remove('active');
  }
}

function inputNumber(num) {
  if (currentPin.length < maxPinLength) {
    currentPin += num;
    updateSlots();
  }
}

function deleteLast() {
  if (currentPin.length > 0) {
    currentPin = currentPin.slice(0, -1);
    updateSlots();
  }
}

function clearPin() {
  currentPin = "";
  updateSlots();
}

function confirmPin() {
  if (currentPin.length === maxPinLength) {
    $.post('https://hyd-keypad/complete', JSON.stringify({
      pin: currentPin
    }));
    hideGui();
  }
}

function hideGui() {
  $("#wrap").css("display", "none");
  currentPin = "";
  updateSlots();
}

function closeGui() {
  hideGui();
  $.post('https://hyd-keypad/close', JSON.stringify({}));
}

window.addEventListener('message', function (event) {
  var item = event.data;

  if (item.open === true) {
    $("#wrap").css("display", "flex");
    currentPin = "";
    updateSlots();
  }
  if (item.close === true) {
    hideGui();
  }
});

// FiveM dışında (tarayıcıda doğrudan açıldığında) arayüzün görünür kalmasını sağlar.
$(document).ready(function () {
  if (!window.invokeNative) {
    $("#wrap").css("display", "flex");
  } else {
    $("#wrap").css("display", "none");
  }
  updateSlots();
});

document.onkeyup = function (data) {
  if (data.which == 27) { // ESC
    closeGui();
  } else if (data.which == 13) { // Enter
    confirmPin();
  } else if (data.which == 8) { // Backspace
    deleteLast();
  } else if (data.which >= 48 && data.which <= 57) { // 0-9
    inputNumber(data.key);
  } else if (data.which >= 96 && data.which <= 105) { // NumPad 0-9
    inputNumber(data.key);
  }
};
