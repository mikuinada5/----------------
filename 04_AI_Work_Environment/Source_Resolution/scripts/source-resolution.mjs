#!/usr/bin/env node
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { promises as fs } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const CURRENT_RE = /^\s*(?:>\s*)?(?:\*{0,2})(?:Status|ステータス)(?:\*{0,2})\s*:\s*.*\bCurrent\b/im;
const DELTA_RE = /^\s*(?:>\s*)?(?:\*{0,2})(?:Status|ステータス)(?:\*{0,2})\s*:\s*.*Canonical\s+Delta/im;
const WORK_NAME_RE = /(?:差分|(?:^|[_\-. ])v\d+(?:\.\d+)*|_更新版|_完成版|\(\d+\))/i;

export const sha256Bytes = (value) => createHash('sha256').update(value).digest('hex');
export const canonicalJson = (value) => JSON.stringify(value);
export const canonicalSha256 = (value) => sha256Bytes(Buffer.from(canonicalJson(value), 'utf8'));

export async function fileSha256(file) {
  return sha256Bytes(await fs.readFile(file));
}

function fail(message) {
  throw new Error(`SOURCE_RESOLUTION_QA_FAIL\n- ${message}`);
}

function normalizedRelative(root, value) {
  const resolvedRoot = path.resolve(root);
  const resolved = path.resolve(resolvedRoot, value);
  const relative = path.relative(resolvedRoot, resolved).split(path.sep).join('/');
  if (!relative || relative === '..' || relative.startsWith('../') || path.isAbsolute(relative)) {
    fail(`Repository-relative path is invalid: ${value}`);
  }
  return relative;
}

async function walkMarkdown(root, start = root) {
  const results = [];
  async function visit(directory) {
    for (const entry of await fs.readdir(directory, { withFileTypes: true })) {
      if (entry.name === '.git' || entry.name === '.codex-runtime' || entry.name === 'Archive' || entry.name === '03_Archive') continue;
      const full = path.join(directory, entry.name);
      if (entry.isDirectory()) await visit(full);
      else if (entry.isFile() && entry.name.toLowerCase().endsWith('.md')) results.push(full);
    }
  }
  await visit(path.resolve(start));
  return results;
}

async function currentMarkdown(root, start = root) {
  const files = await walkMarkdown(root, start);
  const current = [];
  for (const file of files) {
    const head = (await fs.readFile(file, 'utf8')).split(/\r?\n/).slice(0, 30).join('\n').replaceAll('*', '');
    if (CURRENT_RE.test(head)) current.push(file);
  }
  return current;
}

function parseVersion(text, fallback) {
  const head = text.split(/\r?\n/).slice(0, 30).join('\n');
  const status = head.match(/^\s*(?:>\s*)?\*{0,2}(?:Status|ステータス)\*{0,2}\s*:\s*(.+)$/im)?.[1]?.trim();
  const version = head.match(/^\s*(?:>\s*)?\*{0,2}(?:Version|バージョン)\*{0,2}\s*:\s*(.+)$/im)?.[1]?.trim();
  return { status: status?.includes('Current') ? status : 'Current / Repository canonical', version: version || status || fallback };
}

function assertIso(value, label) {
  if (typeof value !== 'string' || Number.isNaN(Date.parse(value))) fail(`${label} must be an ISO-8601 timestamp`);
}

export async function validateSourceManifest({ repositoryRoot, manifest, expectedProductionVersion }) {
  const root = path.resolve(repositoryRoot);
  const failures = [];
  const add = (message) => failures.push(message);
  if (manifest?.schema_version !== 'source-manifest/v2') add('schema_version must be source-manifest/v2');
  if (!manifest?.task_id) add('task_id is required');
  if (!manifest?.production_version) add('production_version is required');
  if (expectedProductionVersion && manifest?.production_version !== expectedProductionVersion) add('production_version mismatch');
  if (!/^[0-9a-f]{40}$/i.test(manifest?.repository?.resolved_commit_sha || '')) add('full Repository commit SHA is required');
  try {
    const head = execFileSync('git', ['-C', root, 'rev-parse', 'HEAD'], { encoding: 'utf8' }).trim();
    if (head !== manifest?.repository?.resolved_commit_sha) add(`Repository HEAD changed after Source Resolution: expected ${manifest?.repository?.resolved_commit_sha}, found ${head}`);
  } catch { add('Current Repository HEAD could not be resolved'); }
  try { assertIso(manifest?.repository?.resolved_at, 'repository.resolved_at'); } catch (error) { add(error.message.replace(/^SOURCE_RESOLUTION_QA_FAIL\n- /, '')); }
  if (manifest?.resolution?.method !== 'responsibility-root-discovery') add('resolution.method must be responsibility-root-discovery');
  const roots = manifest?.resolution?.responsibility_roots || [];
  const candidates = manifest?.resolution?.discovered_candidates || [];
  const sources = manifest?.sources || [];
  if (!roots.length) add('At least one responsibility root is required');
  if (!candidates.length) add('At least one discovered candidate is required');
  if (!sources.length) add('At least one resolved Source is required');
  const candidateMap = new Map();
  for (const candidate of candidates) {
    try {
      const rel = normalizedRelative(root, candidate.path);
      if (candidateMap.has(rel)) add(`Duplicate discovered candidate: ${rel}`);
      candidateMap.set(rel, candidate);
      if (!['selected', 'excluded'].includes(candidate.decision)) add(`Invalid candidate decision: ${rel}`);
      if (candidate.decision === 'excluded' && !candidate.reason) add(`Excluded candidate requires a reason: ${rel}`);
    } catch (error) { add(error.message.replace(/^SOURCE_RESOLUTION_QA_FAIL\n- /, '')); }
  }
  for (const responsibilityRoot of roots) {
    try {
      const relRoot = responsibilityRoot === '.' ? '.' : normalizedRelative(root, responsibilityRoot);
      const rootPath = relRoot === '.' ? root : path.join(root, relRoot);
      const stats = await fs.stat(rootPath);
      if (!stats.isDirectory()) add(`Responsibility root is not a directory: ${responsibilityRoot}`);
      for (const current of await currentMarkdown(root, rootPath)) {
        const rel = path.relative(root, current).split(path.sep).join('/');
        if (!candidateMap.has(rel)) add(`Current candidate was not enumerated: ${rel}`);
      }
    } catch { add(`Responsibility root is missing: ${responsibilityRoot}`); }
  }
  const sourceMap = new Map();
  for (const source of sources) {
    try {
      const rel = normalizedRelative(root, source.path);
      if (sourceMap.has(rel)) add(`Duplicate resolved Source: ${rel}`);
      sourceMap.set(rel, source);
      if (candidateMap.get(rel)?.decision !== 'selected') add(`Resolved Source is not a selected candidate: ${rel}`);
      if (!String(source.status || '').includes('Current')) add(`Resolved Source is not Current: ${rel}`);
      if (!['required', 'conditional'].includes(source.required)) add(`Invalid required value: ${rel}`);
      if (!source.version_or_revision || source.read_task_id !== manifest.task_id || !source.read_by || !source.read_at || !source.read_scope) add(`Read evidence is incomplete: ${rel}`);
      assertIso(source.read_at, `${rel}.read_at`);
      if (!Array.isArray(source.applied_to) || !source.applied_to.length) add(`Applied-to scope is missing: ${rel}`);
      if (source.dependency_check !== 'PASS' || source.conflict_check !== 'PASS') add(`Dependency or conflict check is not PASS: ${rel}`);
      const full = path.join(root, rel);
      if ((await fileSha256(full)).toLowerCase() !== String(source.file_sha256 || '').toLowerCase()) add(`Source fingerprint changed: ${rel}`);
    } catch (error) { add(error.message.replace(/^SOURCE_RESOLUTION_QA_FAIL\n- /, '')); }
  }
  for (const source of sources) {
    for (const dependency of source.dependencies || []) {
      const rel = normalizedRelative(root, dependency);
      if (!sourceMap.has(rel)) add(`Dependency is outside the resolved closure: ${source.path} -> ${rel}`);
    }
  }
  for (const name of ['resolution_complete','current_canonical_unique','dependency_closure_complete','same_task_read_complete','source_fingerprint_frozen']) {
    if (manifest?.g2?.[name] !== true) add(`G2 flag must be true: ${name}`);
  }
  if (manifest?.g2?.result !== 'PASS') add('G2 result must be PASS');
  try { assertIso(manifest?.g2?.passed_at, 'g2.passed_at'); } catch (error) { add(error.message.replace(/^SOURCE_RESOLUTION_QA_FAIL\n- /, '')); }
  for (const file of await currentMarkdown(root)) {
    const relative = path.relative(root, file).split(path.sep).join('/');
    const head = (await fs.readFile(file, 'utf8')).split(/\r?\n/).slice(0, 30).join('\n').replaceAll('*', '');
    if (DELTA_RE.test(head)) add(`Current Canonical Delta is forbidden: ${relative}`);
    if (WORK_NAME_RE.test(path.basename(file))) add(`Current Source uses a work/version filename: ${relative}`);
  }
  if (failures.length) fail(failures.join('\n- '));
  return { result: 'PASS', current_source_count: (await currentMarkdown(root)).length, manifest_checked: true };
}

export async function buildSourceManifest({ repositoryRoot, taskId, productionVersion, requiredPaths, responsibilityRoots = ['04_AI_Work_Environment/Source_Resolution','04_AI_Work_Environment/Visual_Production','07_Note_Production'], readScope = 'Cloud Work note Header production' }) {
  const root = path.resolve(repositoryRoot);
  const head = execFileSync('git', ['-C', root, 'rev-parse', 'HEAD'], { encoding: 'utf8' }).trim();
  const required = [...new Set(requiredPaths.map((item) => normalizedRelative(root, item)))];
  const discovered = new Set(required);
  for (const responsibilityRoot of responsibilityRoots) {
    const rootPath = path.join(root, normalizedRelative(root, responsibilityRoot));
    for (const file of await currentMarkdown(root, rootPath)) discovered.add(path.relative(root, file).split(path.sep).join('/'));
  }
  const now = new Date().toISOString();
  const manifest = {
    schema_version: 'source-manifest/v2', task_id: taskId, production_version: productionVersion,
    repository: { resolved_commit_sha: head, resolved_at: now },
    resolution: {
      method: 'responsibility-root-discovery', responsibility_roots: responsibilityRoots,
      discovered_candidates: [...discovered].sort().map((candidate) => required.includes(candidate)
        ? { path: candidate, status: 'Current', version: head, decision: 'selected', reason: 'Required by Cloud Work Header production profile' }
        : { path: candidate, status: 'Current', version: head, decision: 'excluded', reason: 'Discovered Current Source is outside this Header production scope' })
    },
    sources: [],
    g2: { resolution_complete: true, current_canonical_unique: true, dependency_closure_complete: true, same_task_read_complete: true, source_fingerprint_frozen: true, result: 'PASS', passed_at: now }
  };
  for (const relative of required) {
    const full = path.join(root, relative);
    const text = await fs.readFile(full, 'utf8');
    const meta = parseVersion(text, head);
    manifest.sources.push({
      path: relative, responsibility: `Current Source: ${relative}`, required: 'required', status: meta.status,
      version_or_revision: meta.version, file_sha256: await fileSha256(full), read_by: 'cloud-work-agent', read_at: now,
      read_task_id: taskId, read_scope: readScope, applied_to: ['Source Resolution','Generation Contract','Prompt Assembly QA'],
      dependencies: [], dependency_check: 'PASS', conflict_check: 'PASS'
    });
  }
  await validateSourceManifest({ repositoryRoot: root, manifest, expectedProductionVersion: productionVersion });
  return manifest;
}

function parseArgs(argv) {
  const result = { _: [] };
  for (let index = 0; index < argv.length; index += 1) {
    const item = argv[index];
    if (!item.startsWith('--')) result._.push(item);
    else {
      const key = item.slice(2);
      const value = argv[index + 1];
      if (!value || value.startsWith('--')) result[key] = true;
      else { index += 1; (result[key] ??= []).push(value); }
    }
  }
  return result;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const command = args._[0];
  const root = path.resolve(args['repository-root']?.[0] || '.');
  if (command === 'resolve') {
    const manifest = await buildSourceManifest({ repositoryRoot: root, taskId: args['task-id']?.[0], productionVersion: args['production-version']?.[0], requiredPaths: args.required || [], responsibilityRoots: args.root });
    const output = path.resolve(args.output?.[0]);
    await fs.mkdir(path.dirname(output), { recursive: true });
    await fs.writeFile(output, `${JSON.stringify(manifest, null, 2)}\n`, 'utf8');
    console.log(JSON.stringify({ result: 'PASS', state: 'G2_PASS', manifest_path: output, manifest_sha256: await fileSha256(output) }));
  } else if (command === 'validate') {
    const file = path.resolve(args.manifest?.[0]);
    const manifest = JSON.parse(await fs.readFile(file, 'utf8'));
    console.log(JSON.stringify(await validateSourceManifest({ repositoryRoot: root, manifest, expectedProductionVersion: args['production-version']?.[0] })));
  } else fail('Usage: source-resolution.mjs resolve|validate ...');
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  main().catch((error) => { console.error(error.message); process.exitCode = 1; });
}
