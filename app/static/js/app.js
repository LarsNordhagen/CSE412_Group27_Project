/* ============================================================
   crowdflow / app.js
   Shared helpers: toast notifications + tiny fetch wrapper.
   ============================================================ */

const Toast = (() => {
  const el = document.getElementById("toast");
  let hideTimer = null;

  function show(message, kind = "ok") {
    if (!el) return;
    el.textContent = message;
    el.classList.remove("toast--err", "toast--ok");
    el.classList.add(`toast--${kind}`);
    el.classList.add("is-shown");
    clearTimeout(hideTimer);
    hideTimer = setTimeout(() => el.classList.remove("is-shown"), 3200);
  }
  return { show };
})();

const api = {
  async json(method, url, body) {
    const opts = {
      method,
      headers: { "Content-Type": "application/json" },
    };
    if (body !== undefined) opts.body = JSON.stringify(body);

    const res = await fetch(url, opts);
    let data = null;
    try { data = await res.json(); } catch (_) { /* no body */ }

    if (!res.ok) {
      const err = (data && data.error) || `${res.status} ${res.statusText}`;
      throw new Error(err);
    }
    return data;
  },
  get:    (url)         => api.json("GET",    url),
  post:   (url, body)   => api.json("POST",   url, body),
  patch:  (url, body)   => api.json("PATCH",  url, body),
  remove: (url)         => api.json("DELETE", url),
};

window.Toast = Toast;
window.api = api;
