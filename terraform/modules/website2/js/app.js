document.addEventListener("DOMContentLoaded", () => {
  const el = document.getElementById("js-status");
  if (el) {
    el.textContent =
      "✅ JS asset loaded correctly from MinIO with content-type application/javascript.";
  }
});