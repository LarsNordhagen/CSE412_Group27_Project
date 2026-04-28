/* ============================================================
   crowdflow / seatmap.js
   Handles seat selection + booking creation (CREATE).
   ============================================================ */

(() => {
  const form = document.getElementById("booking-form");
  if (!form) return;

  const eventId = parseInt(form.dataset.eventId, 10);
  const readout = document.getElementById("selected-readout");
  const seatInputs = form.querySelectorAll('input[name="seat_ids"]');
  const userSelect = form.querySelector('select[name="user_id"]');

  function refreshReadout() {
    const picked = Array.from(seatInputs)
      .filter((i) => i.checked)
      .map((i) => parseInt(i.value, 10));
    readout.textContent = picked.length
      ? `[ ${picked.join(", ")} ]`
      : "[ ]";
  }
  seatInputs.forEach((i) => i.addEventListener("change", refreshReadout));

  form.addEventListener("submit", async (ev) => {
    ev.preventDefault();
    const seat_ids = Array.from(seatInputs)
      .filter((i) => i.checked)
      .map((i) => parseInt(i.value, 10));

    if (!seat_ids.length) {
      Toast.show("Pick at least one seat first.", "err");
      return;
    }

    try {
      const booking = await api.post("/api/bookings", {
        event_id: eventId,
        user_id: parseInt(userSelect.value, 10),
        seat_ids,
      });
      Toast.show(`Booking #${booking.booking_id} reserved · seats ${booking.seat_ids}`, "ok");
      // Disable just-booked seats so the UI matches DB state
      seat_ids.forEach((sid) => {
        const input = form.querySelector(`input[value="${sid}"]`);
        if (!input) return;
        input.checked = false;
        input.disabled = true;
        input.closest(".seat").classList.add("seat--taken");
      });
      refreshReadout();
    } catch (err) {
      Toast.show(err.message || "Could not reserve.", "err");
    }
  });
})();
