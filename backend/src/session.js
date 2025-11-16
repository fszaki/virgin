// Minimaler In-Memory-Store (flüchtig, nur für Dev)
const sessions = new Map();

/**
 * Beendet eine Session und entfernt sie aus dem Store.
 * @param {string} sessionId
 * @param {{ reason?: string }} [opts]
 * @returns {{ ok: true, status: 'ended'|'not_found', sessionId: string, reason?: string|null, endedAt?: string }}
 */
export function session_end(sessionId, opts = {}) {
  if (!sessionId || typeof sessionId !== 'string') {
    throw new Error('sessionId erforderlich');
  }

  const exists = sessions.has(sessionId);
  if (!exists) {
    return { ok: true, status: 'not_found', sessionId };
  }

  sessions.delete(sessionId);
  return {
    ok: true,
    status: 'ended',
    sessionId,
    reason: opts.reason ?? null,
    endedAt: new Date().toISOString(),
  };
}

// SemVer- und Datumsprüfungen
const SEMVER_RE = /^\d+\.\d+\.\d+(?:-[0-9A-Za-z-.]+)?$/;
function isISODate(s) {
  if (typeof s !== 'string') return false;
  const d = new Date(s);
  return !Number.isNaN(d.valueOf()) && s === d.toISOString();
}

// Dokumentationsprüfung
function validateSingleDoc(doc, index) {
  const errors = [];
  if (typeof doc !== 'object' || doc === null) {
    return { ok: false, index, id: undefined, errors: ['Dokument ist kein Objekt'] };
  }
  const { id, title, version, lastUpdated, sections } = doc;
  if (typeof title !== 'string' || title.trim().length === 0) errors.push('title fehlt/leer');
  if (typeof version !== 'string' || !SEMVER_RE.test(version)) errors.push('version kein SemVer');
  if (typeof lastUpdated !== 'string' || !isISODate(lastUpdated)) errors.push('lastUpdated kein ISO-String');
  if (!Array.isArray(sections) || sections.length === 0) errors.push('sections fehlt/leer');
  return { ok: errors.length === 0, index, id, errors };
}

export function validate_documentations(docs = []) {
  const details = Array.isArray(docs) ? docs.map((d, i) => validateSingleDoc(d, i)) : [validateSingleDoc(docs, 0)];
  const passed = details.filter(d => d.ok).length;
  return {
    total: details.length,
    passed,
    failed: details.length - passed,
    details
  };
}

// Strukturprüfung (Baum/Nodeliste)
function validateNode(node, path = 'root') {
  const errs = [];
  let count = 0;
  if (typeof node !== 'object' || node === null) return { errors: [`${path}: node ist kein Objekt`], nodeCount: 0 };
  const { id, name, children } = node;
  if (typeof id !== 'string' && typeof id !== 'number') errs.push(`${path}: id fehlt/inkorrekt`);
  if (typeof name !== 'string' || name.trim().length === 0) errs.push(`${path}: name fehlt/leer`);
  count += 1;
  if (children !== undefined && !Array.isArray(children)) {
    errs.push(`${path}: children ist kein Array`);
  } else if (Array.isArray(children)) {
    for (let i = 0; i < children.length; i++) {
      const sub = validateNode(children[i], `${path}.children[${i}]`);
      count += sub.nodeCount;
      if (sub.errors.length) errs.push(...sub.errors);
    }
  }
  return { errors: errs, nodeCount: count };
}

export function validate_structures(structures = []) {
  const roots = Array.isArray(structures) ? structures : [structures];
  const details = roots.map((root, i) => {
    const res = validateNode(root, `root[${i}]`);
    return { index: i, ok: res.errors.length === 0, errors: res.errors, nodes: res.nodeCount };
  });
  const passed = details.filter(d => d.ok).length;
  const totalNodes = details.reduce((s, d) => s + d.nodes, 0);
  return {
    total: details.length,
    passed,
    failed: details.length - passed,
    totalNodes,
    details
  };
}

// Statistik-Berechnung (nur numerische Felder)
export function compute_statistics(rows = []) {
  const data = Array.isArray(rows) ? rows : [];
  const numericFields = new Set();
  for (const r of data) {
    if (r && typeof r === 'object') {
      for (const [k, v] of Object.entries(r)) {
        if (typeof v === 'number' && Number.isFinite(v)) numericFields.add(k);
      }
    }
  }
  const fields = {};
  for (const f of numericFields) {
    let count = 0, sum = 0, min = Infinity, max = -Infinity;
    for (const r of data) {
      const v = r?.[f];
      if (typeof v === 'number' && Number.isFinite(v)) {
        count++; sum += v; if (v < min) min = v; if (v > max) max = v;
      }
    }
    fields[f] = count > 0 ? { count, min, max, avg: sum / count } : { count: 0, min: null, max: null, avg: null };
  }
  return { count: data.length, fields };
}

// Gesamtaudit für eine Session
export function session_audit(sessionId, payload = {}) {
  if (!sessionId || typeof sessionId !== 'string') throw new Error('sessionId erforderlich');

  const docs = Array.isArray(payload.docs) ? payload.docs : [];
  const structures = Array.isArray(payload.structures) ? payload.structures : [];
  const statRows = Array.isArray(payload.statistics?.rows) ? payload.statistics.rows
                   : Array.isArray(payload.rows) ? payload.rows
                   : Array.isArray(payload.data) ? payload.data : [];

  const documentation = validate_documentations(docs);
  const struct = validate_structures(structures);
  const statistics = compute_statistics(statRows);

  const now = new Date().toISOString();
  const before = sessions.get(sessionId) || {};
  sessions.set(sessionId, {
    ...before,
    lastAuditAt: now,
    lastAuditSummary: {
      docs: { total: documentation.total, passed: documentation.passed, failed: documentation.failed },
      structures: { total: struct.total, passed: struct.passed, failed: struct.failed, nodes: struct.totalNodes },
      statistics: { count: statistics.count, fields: Object.keys(statistics.fields).length }
    }
  });

  return {
    ok: true,
    sessionId,
    timestamp: now,
    checks: {
      documentation,
      structures: struct,
      statistics
    }
  };
}

// Optional: einfache Hilfsfunktionen für Tests/Dev
export function __session_add(sessionId, data = {}) { sessions.set(sessionId, data); }
export function __session_has(sessionId) { return sessions.has(sessionId); }
