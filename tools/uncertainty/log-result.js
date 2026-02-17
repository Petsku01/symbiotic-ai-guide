#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const DEFAULT_PATH = path.resolve(process.cwd(), 'research/uncertainty-abstention/logs/pilot-results.jsonl');

function usage() {
  console.error('Usage: node tools/uncertainty/log-result.js <json-string> [jsonl-path]');
  process.exit(1);
}

const payload = process.argv[2];
if (!payload) usage();

let obj;
try {
  obj = JSON.parse(payload);
} catch (err) {
  console.error(`Invalid JSON: ${err.message}`);
  process.exit(1);
}

obj.ts = obj.ts || new Date().toISOString();
const target = process.argv[3] ? path.resolve(process.argv[3]) : DEFAULT_PATH;
fs.mkdirSync(path.dirname(target), { recursive: true });
fs.appendFileSync(target, JSON.stringify(obj) + '\n');
console.log(`Logged to ${target}`);
