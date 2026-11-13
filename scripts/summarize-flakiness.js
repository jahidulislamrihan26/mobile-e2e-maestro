// Reads the JUnit reports written by scripts/flakiness.sh and prints a Markdown table: for every test, how many runs passed.
// A test that both passed and failed across identical runs is "flaky"; one that always fails is "broken", not flaky.
//   node scripts/summarize-flakiness.js [reports/flaky]
const fs = require('fs');
const path = require('path');

const dir = process.argv[2] || 'reports/flaky';
const files = fs.existsSync(dir) ? fs.readdirSync(dir).filter((f) => /^run-\d+\.xml$/.test(f)) : [];
if (files.length === 0) {
  console.log('No JUnit reports found in ' + dir);
  process.exit(0);
}

const unescape = (s) => s.replace(/&quot;/g, '"').replace(/&apos;/g, "'").replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&');
const stats = new Map(); // name -> { pass, fail, times: [] }
for (const f of files) {
  const xml = fs.readFileSync(path.join(dir, f), 'utf8');
  for (const m of xml.matchAll(/<testcase\b([^>]*)>/g)) {
    const attrs = m[1];
    const name = unescape((attrs.match(/\bname="([^"]*)"/) || [])[1] || 'unknown');
    const status = (attrs.match(/\bstatus="([^"]*)"/) || [])[1];
    const time = parseFloat((attrs.match(/\btime="([^"]*)"/) || [])[1] || '0');
    const s = stats.get(name) || { pass: 0, fail: 0, times: [] };
    if (status === 'SUCCESS') s.pass++; else s.fail++;
    s.times.push(time);
    stats.set(name, s);
  }
}

const runs = files.length;
const rows = [...stats.entries()].sort((a, b) => a[0].localeCompare(b[0]));
const verdict = (s) => (s.fail === 0 ? 'stable' : s.pass === 0 ? 'broken' : 'FLAKY');
const median = (a) => { const x = [...a].sort((p, q) => p - q); return x[Math.floor(x.length / 2)]; };

const out = [];
out.push(`## Flakiness: ${runs} identical runs`);
out.push('');
out.push('| Test | Passed | Failed | Pass rate | Median time | Verdict |');
out.push('|---|---:|---:|---:|---:|---|');
let total = 0, passed = 0;
for (const [name, s] of rows) {
  total += s.pass + s.fail; passed += s.pass;
  const rate = ((s.pass / (s.pass + s.fail)) * 100).toFixed(0) + '%';
  out.push(`| ${name} | ${s.pass} | ${s.fail} | ${rate} | ${median(s.times).toFixed(0)} s | ${verdict(s)} |`);
}
out.push('');
out.push(`Overall: ${passed} of ${total} test executions passed (${((passed / total) * 100).toFixed(1)}%).`);
console.log(out.join('\n'));
