import test from 'node:test';
import assert from 'node:assert/strict';
import {
  validate_documentations,
  validate_structures,
  compute_statistics,
  session_audit,
  session_end,
  __session_add,
  __session_has,
} from '../src/session.js';

test('validate_documentations: accepts valid doc and rejects invalid', () => {
  const now = new Date().toISOString();
  const good = validate_documentations([
    { title: 'Doc', version: '1.2.3', lastUpdated: now, sections: ['a'] },
  ]);
  assert.equal(good.total, 1);
  assert.equal(good.passed, 1);
  assert.equal(good.failed, 0);

  const bad = validate_documentations([
    { title: '', version: 'not-semver', lastUpdated: 'yesterday', sections: [] },
  ]);
  assert.equal(bad.total, 1);
  assert.equal(bad.passed, 0);
  assert.equal(bad.failed, 1);
});

test('validate_structures: counts nodes and errors', () => {
  const tree = { id: 'r', name: 'root', children: [{ id: 1, name: 'n1' }] };
  const res = validate_structures([tree]);
  assert.equal(res.total, 1);
  assert.equal(res.passed, 1);
  assert.equal(res.failed, 0);
  assert.equal(res.totalNodes, 2);

  const bad = validate_structures([{ name: '', children: 'nope' }]);
  assert.equal(bad.failed, 1);
});

test('compute_statistics: aggregates numeric fields', () => {
  const stats = compute_statistics([
    { a: 1, b: 10 },
    { a: 3, b: 20 },
    { a: 5 },
  ]);
  assert.equal(stats.count, 3);
  assert.ok('a' in stats.fields);
  assert.equal(stats.fields.a.count, 3);
  assert.equal(stats.fields.a.min, 1);
  assert.equal(stats.fields.a.max, 5);
  assert.equal(stats.fields.a.avg, (1 + 3 + 5) / 3);
  assert.ok('b' in stats.fields);
  assert.equal(stats.fields.b.count, 2);
});

test('session_audit: composes validations and updates store', () => {
  const sid = 'test-session-1';
  const now = new Date().toISOString();
  const res = session_audit(sid, {
    docs: [{ title: 'Doc', version: '1.0.0', lastUpdated: now, sections: ['x'] }],
    structures: [{ id: 'r', name: 'root' }],
    rows: [{ n: 1 }, { n: 2 }],
  });
  assert.equal(res.ok, true);
  assert.equal(res.sessionId, sid);
  assert.equal(res.checks.documentation.passed, 1);
  assert.equal(res.checks.structures.passed, 1);
  assert.equal(res.checks.statistics.count, 2);
});

test('session_end: handles not_found and ended', () => {
  const sid = 'test-session-2';
  const notFound = session_end(sid);
  assert.equal(notFound.ok, true);
  assert.equal(notFound.status, 'not_found');

  __session_add(sid, { foo: 'bar' });
  assert.equal(__session_has(sid), true);
  const ended = session_end(sid, { reason: 'done' });
  assert.equal(ended.ok, true);
  assert.equal(ended.status, 'ended');
  assert.equal(ended.reason, 'done');
});
