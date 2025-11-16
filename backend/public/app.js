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

// Session Audit
const btnAudit = document.getElementById('btnAudit');
const auditOut = document.getElementById('auditOutput');
const auditSessionInput = document.getElementById('auditSessionId');

btnAudit.addEventListener('click', async () => {
  const sessionId = auditSessionInput.value.trim();
  if (!sessionId) {
    auditOut.textContent = 'Fehler: Session ID erforderlich';
    return;
  }

  auditOut.textContent = 'Audit läuft...';
  
  // Beispieldaten für Test
  const payload = {
    sessionId,
    docs: [
      { id: 1, title: 'Benutzerhandbuch', version: '1.0.0', lastUpdated: new Date().toISOString(), sections: ['Intro', 'API'] },
      { id: 2, title: 'API-Docs', version: '2.1.3', lastUpdated: new Date().toISOString(), sections: ['Auth', 'Endpoints'] }
    ],
    structures: [
      { id: 'root', name: 'Hauptmenü', children: [
        { id: 'sub1', name: 'Einstellungen' },
        { id: 'sub2', name: 'Profile', children: [{ id: 'sub2a', name: 'Admin' }] }
      ]}
    ],
    rows: [
      { id: 1, value: 100, score: 85.5 },
      { id: 2, value: 200, score: 92.3 },
      { id: 3, value: 150, score: 78.1 }
    ]
  };

  try {
    const res = await fetch('/api/session/audit', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    auditOut.textContent = JSON.stringify(data, null, 2);
  } catch (err) {
    auditOut.textContent = `Fehler: ${err.message}`;
  }
});
