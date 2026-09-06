#!/usr/bin/env node
import { promises as fs } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { canonicalSha256, fileSha256 } from '../../../04_AI_Work_Environment/Source_Resolution/scripts/source-resolution.mjs';
import { validateFormalHeaderAsset } from '../../../04_AI_Work_Environment/Visual_Production/scripts/cloud-work-header-bridge.mjs';

function fail(code, detail = '') { throw new Error(`BLOCKED_FINAL_PACKAGE_INCOMPLETE: ${code}${detail ? `: ${detail}` : ''}`); }
function requireValue(condition, code, detail = '') { if (!condition) fail(code, detail); }
function exactKeys(value, required, allowed, code) {
  requireValue(value && typeof value === 'object' && !Array.isArray(value), code);
  for (const key of required) requireValue(Object.hasOwn(value, key), code, `missing ${key}`);
  for (const key of Object.keys(value)) requireValue(allowed.includes(key), code, `unexpected ${key}`);
}
function safeArticle(value) { const safe = String(value).replace(/[^A-Za-z0-9._-]/g, '-').replace(/^-+|-+$/g, ''); requireValue(safe, 'ARTICLE_ID_NOT_FILESYSTEM_SAFE'); return safe; }
async function readJson(file, code) { try { return JSON.parse(await fs.readFile(file, 'utf8')); } catch (error) { fail(code, error.message); } }
function resolveArtifact(inputDirectory, localPath) { return path.isAbsolute(localPath) ? path.resolve(localPath) : path.resolve(inputDirectory, localPath); }
async function checkedArtifact(inputDirectory, artifact, label) {
  requireValue(artifact?.artifact_id && artifact?.file && artifact?.local_path && /^[0-9a-f]{64}$/i.test(artifact?.sha256 || ''), `${label}_SCHEMA_FAIL`);
  const resolved = resolveArtifact(inputDirectory, artifact.local_path);
  const actual = await fileSha256(resolved);
  requireValue(actual === artifact.sha256.toLowerCase(), `${label}_SHA_MISMATCH`, `expected=${artifact.sha256.toLowerCase()} actual=${actual}`);
  return { path: resolved, sha256: actual };
}

export function normalizePublicationConditions(conditions) {
  requireValue(conditions?.access_boundary && conditions?.membership && conditions?.magazine && conditions?.price && Array.isArray(conditions?.tags) && Array.isArray(conditions?.other_conditions), 'PUBLICATION_CONDITIONS_SCHEMA_FAIL');
  requireValue(['FREE','PAID','MEMBERSHIP'].includes(conditions.access_boundary.mode) && conditions.access_boundary.free_end_marker && conditions.access_boundary.membership_start_marker, 'PUBLICATION_CONDITIONS_BOUNDARY_INCOMPLETE');
  requireValue(conditions.price.currency === 'JPY' && Number.isInteger(conditions.price.amount) && conditions.price.amount >= 0, 'PUBLICATION_CONDITIONS_PRICE_INVALID');
  requireValue(conditions.tags.length > 0 && conditions.tags.every(Boolean) && new Set(conditions.tags).size === conditions.tags.length, 'PUBLICATION_CONDITIONS_TAGS_INVALID');
  if (conditions.membership.enabled) requireValue(conditions.membership.name && conditions.membership.plan, 'MEMBERSHIP_INCOMPLETE');
  if (conditions.magazine.enabled) requireValue(conditions.magazine.name, 'MAGAZINE_INCOMPLETE');
  return {
    access_boundary: { mode: String(conditions.access_boundary.mode), free_end_marker: String(conditions.access_boundary.free_end_marker), membership_start_marker: String(conditions.access_boundary.membership_start_marker) },
    membership: { enabled: Boolean(conditions.membership.enabled), name: String(conditions.membership.name), plan: String(conditions.membership.plan) },
    magazine: { enabled: Boolean(conditions.magazine.enabled), name: String(conditions.magazine.name) },
    price: { currency: String(conditions.price.currency), amount: Number(conditions.price.amount) },
    tags: [...conditions.tags].sort(), other_conditions: [...conditions.other_conditions].sort()
  };
}

export function finalReviewIdentityPayload(packageValue) {
  return {
    article_id: packageValue.article_id, title: packageValue.title,
    d3_body: { artifact_id: packageValue.d3_body.artifact_id, file: packageValue.d3_body.file, sha256: packageValue.d3_body.sha256.toLowerCase() },
    marketing_review: { status: packageValue.marketing_review.status, identity: packageValue.marketing_review.identity, version: packageValue.marketing_review.version, evidence: { artifact_id: packageValue.marketing_review.evidence.artifact_id, file: packageValue.marketing_review.evidence.file, sha256: packageValue.marketing_review.evidence.sha256.toLowerCase() } },
    header: {
      asset_id: packageValue.header.asset_id, display_title: packageValue.header.display_title, formal_asset_state: packageValue.header.formal_asset_state,
      formal_asset_identity_sha256: packageValue.header.formal_asset_identity_sha256.toLowerCase(), file: packageValue.header.file, sha256: packageValue.header.sha256.toLowerCase(),
      master_template: { asset_id: packageValue.header.master_template.asset_id, version: packageValue.header.master_template.version, canonical_locator: packageValue.header.master_template.canonical_locator, sha256: packageValue.header.master_template.sha256.toLowerCase() },
      route_evidence: { implementation_id: packageValue.header.route_evidence.implementation_id, route: packageValue.header.route_evidence.route, runtime_receipt_sha256: packageValue.header.route_evidence.runtime_receipt_sha256.toLowerCase() },
      asset_qa: { status: packageValue.header.asset_qa.status, evidence: { artifact_id: packageValue.header.asset_qa.evidence.artifact_id, file: packageValue.header.asset_qa.evidence.file, sha256: packageValue.header.asset_qa.evidence.sha256.toLowerCase() } },
      human_approval: { event_id: packageValue.header.human_approval.event_id, evidence_sha256: packageValue.header.human_approval.evidence_sha256.toLowerCase() }
    },
    publication_conditions: normalizePublicationConditions(packageValue.publication_conditions),
    destination: { service: packageValue.destination.service, account_id: packageValue.destination.account_id, publication_target: packageValue.destination.publication_target },
    purpose: packageValue.purpose,
    source_manifest: { manifest_id: packageValue.source_manifest.manifest_id, file: packageValue.source_manifest.file, sha256: packageValue.source_manifest.sha256.toLowerCase() }
  };
}

export function finalReviewIdentity(packageValue) {
  const identity = canonicalSha256(finalReviewIdentityPayload(packageValue));
  return { identity_sha256: identity, package_id: `FRP-${safeArticle(packageValue.article_id)}-${identity}` };
}

function presentation(packageValue, packageSha) {
  const c = packageValue.publication_conditions;
  return `# note Human Final Review Package\n\n- Package ID: ${packageValue.package_id}\n- Package identity SHA-256: ${packageValue.identity_sha256}\n- Package file SHA-256: ${packageSha}\n\n## 1. D3本文\n\n${packageValue.d3_body.content}\n\n## 2. Header\n\n- Title: ${packageValue.header.display_title}\n- File: ${packageValue.header.file}\n- SHA-256: ${packageValue.header.sha256}\n- Formal Asset: ${packageValue.header.asset_id}\n\n## 3. 無料／Membership境界\n\n- Mode: ${c.access_boundary.mode}\n- Free end: ${c.access_boundary.free_end_marker}\n- Membership start: ${c.access_boundary.membership_start_marker}\n\n## 4. Membership\n\n- Enabled: ${c.membership.enabled}\n- Name: ${c.membership.name}\n- Plan: ${c.membership.plan}\n\n## 5. Magazine\n\n- Enabled: ${c.magazine.enabled}\n- Name: ${c.magazine.name}\n\n## 6. 価格\n\n- ${c.price.currency} ${c.price.amount}\n\n## 7. tags\n\n${c.tags.map((tag) => `- ${tag}`).join('\n')}\n\n## 8. その他Publication Conditions\n\n${c.other_conditions.length ? c.other_conditions.map((item) => `- ${item}`).join('\n') : '- none'}\n`;
}

async function writeImmutable(file, text, code) {
  await fs.mkdir(path.dirname(file), { recursive: true });
  try { requireValue(await fs.readFile(file, 'utf8') === text, code); }
  catch (error) { if (error.code === 'ENOENT') await fs.writeFile(file, text, 'utf8'); else throw error; }
}

export async function compileFinalReviewPackage({ repositoryRoot, inputPath, outputDirectory }) {
  const input = await readJson(inputPath, 'FINAL_PACKAGE_INPUT_SCHEMA_FAIL');
  const topKeys = ['schema_version','workflow_state','article_id','title','d3_body','marketing_review','header','publication_conditions','destination','purpose','source_manifest'];
  exactKeys(input, topKeys, topKeys, 'FINAL_PACKAGE_INPUT_SCHEMA_FAIL');
  exactKeys(input.d3_body, ['artifact_id','file','local_path','sha256'], ['artifact_id','file','local_path','sha256'], 'FINAL_PACKAGE_INPUT_SCHEMA_FAIL');
  exactKeys(input.marketing_review, ['status','identity','version','evidence'], ['status','identity','version','evidence'], 'FINAL_PACKAGE_INPUT_SCHEMA_FAIL');
  exactKeys(input.header, ['asset_id','display_title','file','local_path','sha256','formal_asset','asset_qa'], ['asset_id','display_title','file','local_path','sha256','formal_asset','asset_qa'], 'FINAL_PACKAGE_INPUT_SCHEMA_FAIL');
  exactKeys(input.source_manifest, ['manifest_id','file','local_path','sha256'], ['manifest_id','file','local_path','sha256'], 'FINAL_PACKAGE_INPUT_SCHEMA_FAIL');
  requireValue(input.schema_version === 'note-final-review-package-input/v2' && input.workflow_state === 'MARKETING_APPROVED', 'FINAL_PACKAGE_INPUT_SCHEMA_FAIL');
  requireValue(input.article_id && input.title && input.destination?.service === 'note' && input.purpose === 'NOTE_PUBLICATION', 'FINAL_PACKAGE_INPUT_SCHEMA_FAIL');
  const inputDirectory = path.dirname(path.resolve(inputPath));
  const bodyCheck = await checkedArtifact(inputDirectory, input.d3_body, 'D3_BODY');
  const marketingCheck = await checkedArtifact(inputDirectory, input.marketing_review?.evidence, 'MARKETING_REVIEW_EVIDENCE');
  requireValue(input.marketing_review?.status === 'PASS' && input.marketing_review.identity && input.marketing_review.version, 'MARKETING_REVIEW_EVIDENCE_INVALID');
  const headerCheck = await checkedArtifact(inputDirectory, { artifact_id: input.header?.asset_id, file: input.header?.file, local_path: input.header?.local_path, sha256: input.header?.sha256 }, 'HEADER');
  const formalCheck = await checkedArtifact(inputDirectory, input.header?.formal_asset, 'FORMAL_HEADER_ASSET');
  const qaCheck = await checkedArtifact(inputDirectory, input.header?.asset_qa?.evidence, 'HEADER_QA_EVIDENCE');
  const sourceCheck = await checkedArtifact(inputDirectory, { artifact_id: input.source_manifest?.manifest_id, file: input.source_manifest?.file, local_path: input.source_manifest?.local_path, sha256: input.source_manifest?.sha256 }, 'SOURCE_MANIFEST');
  requireValue(input.header.asset_qa.status === 'PASS', 'HEADER_QA_NOT_PASS');
  const bodyContent = await fs.readFile(bodyCheck.path, 'utf8');
  requireValue(bodyContent.length > 0, 'D3_BODY_EMPTY');
  const formal = await readJson(formalCheck.path, 'FORMAL_HEADER_ASSET_INVALID');
  await validateFormalHeaderAsset({ repositoryRoot, formalAssetPath: formalCheck.path, expectedArticleId: input.article_id, expectedHeaderTitle: input.header.display_title, expectedHeaderPath: headerCheck.path, recordOnly: true });
  requireValue(input.header.asset_id === formal.formal_asset_id, 'FORMAL_HEADER_ASSET_ID_MISMATCH');
  requireValue(input.header.file === formal.asset.file && headerCheck.sha256 === formal.asset.sha256, 'FORMAL_HEADER_ASSET_POINTER_MISMATCH');
  requireValue(qaCheck.sha256 === formal.asset_qa.visual_record_sha256, 'FORMAL_HEADER_QA_EVIDENCE_MISMATCH');
  const packageValue = {
    schema_version: 'note-final-review-package/v3', compiler_version: 'note-final-review-package-compiler/v2', package_id: '', identity_sha256: '', state: 'READY_FOR_FINAL_REVIEW', article_id: input.article_id, title: input.title,
    d3_body: { artifact_id: input.d3_body.artifact_id, file: input.d3_body.file, sha256: bodyCheck.sha256, content: bodyContent },
    marketing_review: { status: 'PASS', identity: input.marketing_review.identity, version: input.marketing_review.version, evidence: { artifact_id: input.marketing_review.evidence.artifact_id, file: input.marketing_review.evidence.file, sha256: marketingCheck.sha256 } },
    header: {
      asset_id: formal.formal_asset_id, display_title: formal.approved_header_title, formal_asset_state: 'FORMAL_HEADER_ASSET', formal_asset_identity_sha256: formal.identity_sha256,
      file: input.header.file, sha256: headerCheck.sha256,
      master_template: { asset_id: formal.master_template.asset_id, version: formal.master_template.version, canonical_locator: formal.master_template.canonical_locator, sha256: formal.master_template.actual_sha256 },
      route_evidence: { implementation_id: formal.route_evidence.implementation_id, route: formal.route_evidence.route, runtime_receipt_sha256: formal.route_evidence.runtime_receipt_sha256 },
      asset_qa: { status: 'PASS', evidence: { artifact_id: input.header.asset_qa.evidence.artifact_id, file: input.header.asset_qa.evidence.file, sha256: qaCheck.sha256 } },
      human_approval: { event_id: formal.human_approval.event_id, evidence_sha256: formal.human_approval.evidence_sha256 }
    },
    publication_conditions: normalizePublicationConditions(input.publication_conditions),
    destination: { service: 'note', account_id: input.destination.account_id, publication_target: input.destination.publication_target }, purpose: 'NOTE_PUBLICATION',
    source_manifest: { manifest_id: input.source_manifest.manifest_id, file: input.source_manifest.file, sha256: sourceCheck.sha256 }, approval: { status: 'PENDING' }
  };
  Object.assign(packageValue, finalReviewIdentity(packageValue));
  const outputRoot = path.resolve(outputDirectory);
  const packagePath = path.join(outputRoot, `${packageValue.package_id}.json`);
  const packageText = `${JSON.stringify(packageValue, null, 2)}\n`;
  await writeImmutable(packagePath, packageText, 'IMMUTABLE_PACKAGE_CONFLICT');
  const packageSha = await fileSha256(packagePath);
  const presentationPath = path.join(outputRoot, `${packageValue.package_id}.final-review.md`);
  await writeImmutable(presentationPath, presentation(packageValue, packageSha), 'IMMUTABLE_PRESENTATION_CONFLICT');
  return { result: 'PASS', previous_state: 'MARKETING_APPROVED', build_state: 'FINAL_REVIEW_PACKAGE_BUILDING', state: 'READY_FOR_FINAL_REVIEW', approval_status: 'PENDING', package_id: packageValue.package_id, package_identity_sha256: packageValue.identity_sha256, package_sha256: packageSha, package_path: packagePath, presentation_path: presentationPath };
}

function parseArgs(argv) { const result = { _: [] }; for (let i = 0; i < argv.length; i += 1) { const item = argv[i]; if (!item.startsWith('--')) result._.push(item); else { const value = argv[i + 1]; if (!value || value.startsWith('--')) fail('ARGUMENT_VALUE_REQUIRED', item); result[item.slice(2)] = value; i += 1; } } return result; }

async function main() {
  const args = parseArgs(process.argv.slice(2));
  requireValue(args._[0] === 'compile', 'USAGE', 'final-review-package-compiler.mjs compile --repository-root . --input <json> --output-directory <dir>');
  console.log(JSON.stringify(await compileFinalReviewPackage({ repositoryRoot: path.resolve(args['repository-root'] || '.'), inputPath: path.resolve(args.input), outputDirectory: path.resolve(args['output-directory']) })));
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main().catch((error) => { console.error(error.message); process.exitCode = 1; });
