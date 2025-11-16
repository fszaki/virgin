const btn = document.getElementById('btnFetch');
const out = document.getElementById('output');

btn.addEventListener('click', async () => {
  out.textContent = 'Lade...';
  try {
    const res = await fetch('/api/hello');
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    out.textContent = JSON.stringify(data, null, 2);
  } catch (err) {
    out.textContent = `Fehler: ${err.message}`;
  }
});
