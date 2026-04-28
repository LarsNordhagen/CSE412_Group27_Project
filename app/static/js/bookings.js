/* ============================================================
   crowdflow / bookings.js
   Wires up Pay (INSERT+UPDATE), Cancel (UPDATE), Delete (DELETE).
   ============================================================ */

(() => {
  const table = document.getElementById("bookings-table");
  if (!table) return;

  const modal     = document.getElementById("pay-modal");
  const payForm   = document.getElementById("pay-form");
  const payIdEl   = document.getElementById("pay-booking-id");
  let activeId    = null;

  // ------------------------------------------------------------
  // Per-row action handler (event delegation)
  // ------------------------------------------------------------
  table.addEventListener("click", async (ev) => {
    const btn = ev.target.closest("button[data-action]");
    if (!btn) return;

    const row       = btn.closest("tr");
    const bookingId = parseInt(row.dataset.bookingId, 10);
    const action    = btn.dataset.action;

    if (action === "pay") {
      activeId = bookingId;
      payIdEl.textContent = `#${bookingId}`;
      modal.showModal();
      return;
    }

    if (action === "cancel") {
      if (!confirm(`Cancel booking #${bookingId}? Status will flip to 'cancelled'.`)) return;
      try {
        await api.post(`/api/bookings/${bookingId}/cancel`, {});
        markCancelled(row);
        Toast.show(`Booking #${bookingId} cancelled.`, "ok");
      } catch (err) {
        Toast.show(err.message || "Cancel failed.", "err");
      }
      return;
    }

    if (action === "delete") {
      if (!confirm(`Delete booking #${bookingId}? Payment + attendance will cascade.`)) return;
      try {
        await api.remove(`/api/bookings/${bookingId}`);
        row.remove();
        Toast.show(`Booking #${bookingId} deleted.`, "ok");
      } catch (err) {
        Toast.show(err.message || "Delete failed.", "err");
      }
    }
  });

  // ------------------------------------------------------------
  // Pay modal — POST /api/bookings/:id/pay (INSERT payment + UPDATE booking)
  // ------------------------------------------------------------
  modal?.addEventListener("click", (ev) => {
    if (ev.target.matches("[data-close]")) modal.close();
  });

  payForm?.addEventListener("submit", async (ev) => {
    ev.preventDefault();
    if (!activeId) return;

    const amount = parseFloat(payForm.querySelector('[name="amount"]').value);
    const method = payForm.querySelector('[name="payment_method"]').value;

    try {
      await api.post(`/api/bookings/${activeId}/pay`, {
        amount,
        payment_method: method,
      });
      const row = table.querySelector(`tr[data-booking-id="${activeId}"]`);
      if (row) markPaid(row, amount, method);
      Toast.show(`Booking #${activeId} paid · $${amount.toFixed(2)} (${method}).`, "ok");
      modal.close();
      activeId = null;
    } catch (err) {
      Toast.show(err.message || "Payment failed.", "err");
    }
  });

  // ------------------------------------------------------------
  // Row-state helpers
  // ------------------------------------------------------------
  function markPaid(row, amount, method) {
    row.dataset.status = "confirmed";
    const pill = row.querySelector(".pill");
    if (pill) {
      pill.className = "pill pill--confirmed";
      pill.textContent = "confirmed";
    }
    row.children[5].innerHTML = `$${amount.toFixed(2)} · ${method}`;
    row.querySelector(".actions").innerHTML =
      `<span class="muted small">paid</span>
       <button class="btn btn--xs btn--danger" data-action="delete">Delete</button>`;
  }

  function markCancelled(row) {
    row.dataset.status = "cancelled";
    const pill = row.querySelector(".pill");
    if (pill) {
      pill.className = "pill pill--cancelled";
      pill.textContent = "cancelled";
    }
    row.querySelector(".actions").innerHTML =
      `<span class="muted small">cancelled</span>
       <button class="btn btn--xs btn--danger" data-action="delete">Delete</button>`;
  }
})();
