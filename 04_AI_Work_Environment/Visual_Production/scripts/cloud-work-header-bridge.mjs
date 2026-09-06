#!/usr/bin/env node
import { promises as fs } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { canonicalSha256, fileSha256, sha256Bytes, validateSourceManifest } from '../../Source_Resolution/scripts/source-resolution.mjs';

const MASTER_ID = 'NOTE-HEADER-MASTER-v1.0';
const MASTER_VERSION = 'v1.0';
const PROFILE_ID = 'aidaily-header-v1';
const CLOUD_IMPLEMENTATION = 'repo-skill:visual-production-bridge/cloud-work-v1';
const CLOUD_ROUTE = 'repository-cloud-work-request-bound';
const CANONICAL_HEADER_IDS = [
  'master-reference','note-horizontal','current-dimensions','human-left','kei-right','comic-style','white-background','black-pink-palette',
  'master-title-replace','title-exact','title-central','no-series-label','no-speech-bubbles','no-explanation-copy','no-checklists',
  'no-additional-catch-copy','no-background-recolor','no-unverified-facts','no-hype','no-poster-layout','no-title-change'
];

function fail(code, detail = '') { throw new Error(`${code}${detail ? `: ${detail}` : ''}`); }
function requireValue(condition, code, detail = '') { if (!condition) fail(code, detail); }
function exactKeys(value, required, allowed, code) {
  requireValue(value && typeof value === 'object' && !Array.isArray(value), code);
  for (const key of required) requireValue(Object.hasOwn(value, key), code, `missing ${key}`);
  for (const key of Object.keys(value)) requireValue(allowed.includes(key), code, `unexpected ${key}`);
}
function iso(value, code) { requireValue(typeof value === 'string' && !Number.isNaN(Date.parse(value)), code); return Date.parse(value); }
function safeArticle(value) { const safe = String(value).replace(/[^A-Za-z0-9._-]/g, '-').replace(/^-+|-+$/g, ''); requireValue(safe, 'HEADER_ARTICLE_ID_NOT_SAFE'); return safe; }
function normalizeRel(value) { return String(value).replaceAll('\\', '/'); }

async function readJson(file, code = 'JSON_INVALID') {
  try { return JSON.parse(await fs.readFile(file, 'utf8')); }
  catch (error) { fail(code, error.message); }
}

async function writeImmutableJson(file, value, code) {
  const text = `${JSON.stringify(value, null, 2)}\n`;
  await fs.mkdir(path.dirname(file), { recursive: true });
  try {
    const existing = await fs.readFile(file, 'utf8');
    requireValue(existing === text, code);
  } catch (error) {
    if (error.code === 'ENOENT') await fs.writeFile(file, text, 'utf8');
    else throw error;
  }
  return file;
}

export async function pngDimensions(file) {
  const buffer = await fs.readFile(file);
  const signature = Buffer.from([137,80,78,71,13,10,26,10]);
  requireValue(buffer.length >= 24 && buffer.subarray(0, 8).equals(signature), 'HEADER_IMAGE_NOT_READABLE_PNG');
  requireValue(buffer.subarray(12, 16).toString('ascii') === 'IHDR', 'HEADER_IMAGE_IHDR_MISSING');
  return { width: buffer.readUInt32BE(16), height: buffer.readUInt32BE(20) };
}

function repositoryPath(repositoryRoot, relative, code = 'HEADER_MASTER_LOCATOR_INVALID') {
  requireValue(typeof relative === 'string' && relative && !path.isAbsolute(relative) && !relative.includes('\\') && !normalizeRel(relative).split('/').includes('..'), code);
  const root = path.resolve(repositoryRoot);
  const resolved = path.resolve(root, relative);
  requireValue(resolved.startsWith(`${root}${path.sep}`), code);
  return resolved;
}

function profileBlock(text, profileId = PROFILE_ID) {
  const escaped = profileId.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const block = text.match(new RegExp(`<!--\\s*VISUAL_PROFILE_BEGIN:${escaped}\\s*-->([\\s\\S]*?)<!--\\s*VISUAL_PROFILE_END:${escaped}\\s*-->`));
  requireValue(block, 'VISUAL_CONTRACT_BUILD_FAIL', `canonical profile marker not found: ${profileId}`);
  const metadata = block[1].match(/<!--\s*VISUAL_PROFILE_META:({[\s\S]*?})\s*-->/);
  requireValue(metadata, 'VISUAL_CONTRACT_BUILD_FAIL', `canonical profile metadata not found: ${profileId}`);
  let parsed;
  try { parsed = JSON.parse(metadata[1]); } catch { fail('VISUAL_CONTRACT_BUILD_FAIL', `canonical profile metadata is invalid JSON: ${profileId}`); }
  return { text: block[1], metadata: parsed };
}

export async function resolveMaster({ repositoryRoot, profileSourcePath, profileId = PROFILE_ID }) {
  const root = path.resolve(repositoryRoot);
  const profilePath = path.resolve(profileSourcePath);
  requireValue(profilePath.startsWith(`${root}${path.sep}`), 'HEADER_MASTER_PROFILE_SOURCE_UNRESOLVED');
  const profile = profileBlock(await fs.readFile(profilePath, 'utf8'), profileId);
  const meta = profile.metadata;
  for (const field of ['master_asset_id','master_asset_version','master_asset_locator','master_asset_manifest','master_asset_sha256','width','height']) requireValue(meta[field] !== undefined && meta[field] !== '', 'HEADER_MASTER_PROFILE_METADATA_INCOMPLETE', field);
  requireValue(meta.master_asset_id === MASTER_ID && meta.master_asset_version === MASTER_VERSION, 'HEADER_MASTER_PROFILE_IDENTITY_MISMATCH');
  const masterPath = repositoryPath(root, meta.master_asset_locator);
  const manifestPath = repositoryPath(root, meta.master_asset_manifest);
  const manifest = await readJson(manifestPath, 'HEADER_MASTER_MANIFEST_INVALID');
  requireValue(manifest.schema_version === 'note-header-master-asset/v1' && manifest.asset_id === MASTER_ID && manifest.version === MASTER_VERSION, 'HEADER_MASTER_MANIFEST_IDENTITY_MISMATCH');
  requireValue(manifest.repository_locator === meta.master_asset_locator && manifest.sha256 === String(meta.master_asset_sha256).toLowerCase(), 'HEADER_MASTER_MANIFEST_BINDING_MISMATCH');
  requireValue(manifest.file === path.basename(masterPath), 'HEADER_MASTER_MANIFEST_FILE_MISMATCH');
  requireValue(manifest.dimensions?.width === Number(meta.width) && manifest.dimensions?.height === Number(meta.height), 'HEADER_MASTER_MANIFEST_DIMENSIONS_MISMATCH');
  requireValue(manifest.visual_specification?.profile_id === profileId && manifest.visual_specification?.canonical_source === normalizeRel(path.relative(root, profilePath)), 'HEADER_MASTER_VISUAL_SPECIFICATION_MISMATCH');
  requireValue(manifest.provenance?.repository_copy_relationship === 'byte-identical' && manifest.provenance?.original_archive_locator, 'HEADER_MASTER_PROVENANCE_INVALID');
  const actualSha = await fileSha256(masterPath);
  requireValue(actualSha === String(meta.master_asset_sha256).toLowerCase(), 'HEADER_MASTER_SHA_MISMATCH');
  const dimensions = await pngDimensions(masterPath);
  requireValue(dimensions.width === Number(meta.width) && dimensions.height === Number(meta.height) && dimensions.width === 1280 && dimensions.height === 670, 'HEADER_MASTER_DIMENSIONS_MISMATCH');
  return {
    asset_id: MASTER_ID, version: MASTER_VERSION, canonical_locator: meta.master_asset_locator,
    expected_sha256: String(meta.master_asset_sha256).toLowerCase(), actual_sha256: actualSha,
    width: dimensions.width, height: dimensions.height, manifest_locator: meta.master_asset_manifest,
    provenance: `repository-master-manifest:${meta.master_asset_manifest}`,
    original_archive_locator: manifest.provenance.original_archive_locator,
    actual_path: masterPath, manifest_path: manifestPath, profile
  };
}

function requirementsFromProfile(block, profileRelative) {
  const requirements = [];
  for (const line of block.split(/\r?\n/)) {
    if (!line.startsWith('|')) continue;
    const columns = line.trim().replace(/^\||\|$/g, '').split('|').map((value) => value.trim());
    if (columns.length < 3 || ['ID','---'].includes(columns[0]) || !['MUST','MUST_NOT','MAY'].includes(columns[1])) continue;
    requireValue(columns[0] && columns[2], 'VISUAL_CONTRACT_BUILD_FAIL', 'profile requirement is incomplete');
    requirements.push({ id: columns[0], level: columns[1], text: columns[2], source_path: profileRelative });
  }
  requireValue(requirements.length, 'VISUAL_CONTRACT_BUILD_FAIL', 'profile has no machine-readable requirements');
  return requirements;
}

function contractIdentityPayload({ articleId, approvedTitle, productionVersion, sourceFingerprint, requirements, master, prompt }) {
  return {
    article_id: articleId, approved_header_title: approvedTitle, production_version: productionVersion,
    profile_id: PROFILE_ID, source_manifest_identity: sourceFingerprint, destination: 'NOTE_FINAL_REVIEW_PACKAGE', purpose: 'NOTE_HEADER_ASSET_PRODUCTION',
    dimensions: { width: 1280, height: 670 },
    master_template: { asset_id: master.asset_id, version: master.version, canonical_locator: master.canonical_locator, manifest_locator: master.manifest_locator, sha256: master.actual_sha256 },
    requirements: requirements.map(({ id, level, text, source_path }) => ({ id, level, text, source_path })), prompt
  };
}

export async function validateVisualRecord({ repositoryRoot, record, requireCandidate = false }) {
  requireValue(record.schema_version === 'visual-production/v1', 'VISUAL_PRODUCTION_QA_FAIL', 'schema_version');
  requireValue(record.artifact_type === 'note-header' && record.generation_contract?.profile_id === PROFILE_ID, 'VISUAL_PRODUCTION_QA_FAIL', 'wrong Header profile');
  requireValue(record.preflight?.result === 'PASS', 'VISUAL_PRODUCTION_QA_FAIL', 'Prompt Assembly QA not PASS');
  for (const field of ['tool_route_check','contract_completeness_check','prompt_assembly_check','exact_text_check','negative_constraints_check','reference_asset_check','source_fingerprint_check']) requireValue(record.preflight[field] === true, 'VISUAL_PRODUCTION_QA_FAIL', `preflight ${field}`);
  const requirements = record.resolved_requirements || [];
  const byId = new Map(requirements.map((item) => [item.id, item]));
  for (const id of CANONICAL_HEADER_IDS) requireValue(byId.has(id), 'VISUAL_PRODUCTION_QA_FAIL', `missing canonical requirement: ${id}`);
  const mandatory = requirements.filter((item) => ['MUST','MUST_NOT'].includes(item.level));
  for (const item of mandatory) {
    requireValue(record.generation_contract.requirement_ids.includes(item.id) && record.tool_request.included_requirement_ids.includes(item.id), 'VISUAL_PRODUCTION_QA_FAIL', `omitted requirement: ${item.id}`);
    requireValue(record.tool_request.prompt.includes(item.text), 'VISUAL_PRODUCTION_QA_FAIL', `prompt omitted requirement text: ${item.id}`);
    if (item.level === 'MUST_NOT') requireValue(record.tool_request.negative_requirement_ids.includes(item.id), 'VISUAL_PRODUCTION_QA_FAIL', `omitted negative requirement: ${item.id}`);
  }
  const title = record.generation_contract.approved_text?.title;
  requireValue(title && record.tool_request.text_verbatim === title && record.tool_request.prompt.includes(title), 'VISUAL_PRODUCTION_QA_FAIL', 'approved title mismatch');
  requireValue(record.generation_contract.article_id && record.generation_contract.contract_identity_sha256, 'VISUAL_PRODUCTION_QA_FAIL', 'Article-bound contract identity missing');
  const references = record.generation_contract.reference_assets || [];
  requireValue(references.length === 1 && record.tool_request.referenced_image_paths?.length === 1, 'VISUAL_PRODUCTION_QA_FAIL', 'Master reference missing');
  const master = references[0];
  requireValue(master.asset_id === MASTER_ID && master.expected_sha256 === master.actual_sha256 && master.actual_sha256 === master.sha256, 'VISUAL_PRODUCTION_QA_FAIL', 'Master SHA mismatch');
  const masterPath = repositoryPath(repositoryRoot, master.logical_locator);
  requireValue(path.resolve(record.tool_request.referenced_image_paths[0]) === masterPath, 'VISUAL_PRODUCTION_QA_FAIL', 'actual Master reference is not Repository canonical');
  requireValue(await fileSha256(masterPath) === master.sha256, 'VISUAL_PRODUCTION_QA_FAIL', 'Master bytes mismatch');
  const argumentsValue = { prompt: record.tool_request.prompt, referenced_image_paths: record.tool_request.referenced_image_paths };
  requireValue(canonicalSha256(record.tool_request) === record.generation_contract.request_identity_sha256, 'VISUAL_PRODUCTION_QA_FAIL', 'internal request identity mismatch');
  requireValue(canonicalSha256(argumentsValue) === record.generation_contract.invocation_arguments_sha256, 'VISUAL_PRODUCTION_QA_FAIL', 'invocation arguments identity mismatch');
  if (requireCandidate) {
    requireValue(record.transition?.requested_target === 'HUMAN_REVIEW_CANDIDATE' && record.asset?.status === 'QA_PASS' && record.asset_qa?.performed === true && record.asset_qa?.result === 'PASS', 'VISUAL_PRODUCTION_QA_FAIL', 'Asset QA candidate state missing');
    requireValue(await fileSha256(record.asset.local_path) === record.asset.sha256, 'VISUAL_PRODUCTION_QA_FAIL', 'generated asset bytes mismatch');
    const dims = await pngDimensions(record.asset.local_path);
    requireValue(dims.width === 1280 && dims.height === 670 && record.asset.width === 1280 && record.asset.height === 670, 'VISUAL_PRODUCTION_QA_FAIL', 'generated asset dimensions mismatch');
    const checks = new Map((record.asset_qa.checks || []).map((item) => [item.requirement_id, item.result]));
    for (const item of mandatory) requireValue(checks.get(item.id) === 'PASS', 'VISUAL_PRODUCTION_QA_FAIL', `Asset QA did not pass: ${item.id}`);
    requireValue(checks.get('dimensions') === 'PASS', 'VISUAL_PRODUCTION_QA_FAIL', 'Asset QA dimensions missing');
  }
  return { result: 'PASS', state: requireCandidate ? 'HUMAN_REVIEW_CANDIDATE' : 'TOOL_INVOCATION_PENDING' };
}

export async function prepareGeneration({ repositoryRoot, sourceManifestPath, profileSourcePath, taskId, articleId, productionVersion, approvedTitle, outputDirectory }) {
  const root = path.resolve(repositoryRoot);
  const manifest = await readJson(sourceManifestPath, 'SOURCE_MANIFEST_INVALID');
  await validateSourceManifest({ repositoryRoot: root, manifest, expectedProductionVersion: productionVersion });
  requireValue(manifest.task_id === taskId, 'VISUAL_CONTRACT_BUILD_FAIL', 'Source Manifest task_id mismatch');
  const profilePath = path.resolve(profileSourcePath);
  const profileRelative = normalizeRel(path.relative(root, profilePath));
  requireValue(manifest.sources.filter((item) => normalizeRel(item.path) === profileRelative).length === 1, 'VISUAL_CONTRACT_BUILD_FAIL', 'Profile Source not uniquely resolved');
  const master = await resolveMaster({ repositoryRoot: root, profileSourcePath: profilePath });
  const requirements = requirementsFromProfile(master.profile.text, profileRelative);
  const mandatoryIds = requirements.filter((item) => ['MUST','MUST_NOT'].includes(item.level)).map((item) => item.id);
  const negativeIds = requirements.filter((item) => item.level === 'MUST_NOT').map((item) => item.id);
  const lines = (level) => requirements.filter((item) => item.level === level).map((item) => `- [${item.id}] ${item.text}`).join('\n');
  const prompt = [
    'Create exactly one visual asset under the following validated contract.',
    `Render this approved title verbatim: ${approvedTitle}`,
    'Canvas: 1280x670px (canonical profile dimensions).',
    `Use the required Master reference image exactly as bound: ${master.asset_id} ${master.version}, logical locator ${master.canonical_locator}, SHA-256 ${master.actual_sha256}.`,
    'MUST:', lines('MUST'), 'MUST NOT:', lines('MUST_NOT'),
    'MAY only when it does not conflict with MUST or MUST NOT:', lines('MAY'),
    'Do not add any text other than the approved title unless a canonical MUST explicitly requires it.'
  ].join('\n');
  const sourceRows = [...manifest.sources].sort((a, b) => normalizeRel(a.path).localeCompare(normalizeRel(b.path), 'en')).map((item) => `${normalizeRel(item.path)}|${item.file_sha256.toLowerCase()}`);
  const sourceFingerprint = sha256Bytes(Buffer.from(sourceRows.join('\n'), 'utf8'));
  const toolRequest = {
    text_verbatim: approvedTitle, prompt, dimensions: { width: 1280, height: 670 }, referenced_image_paths: [master.actual_path],
    included_requirement_ids: mandatoryIds, negative_requirement_ids: negativeIds
  };
  const invocationArguments = { prompt, referenced_image_paths: [master.actual_path] };
  const contractPayload = contractIdentityPayload({ articleId, approvedTitle, productionVersion, sourceFingerprint, requirements, master, prompt });
  const record = {
    schema_version: 'visual-production/v1', task_id: taskId, production_version: productionVersion, phase: 'Header Production', artifact_type: 'note-header',
    source_manifest: { task_id: manifest.task_id, production_version: manifest.production_version, result: manifest.g2.result, fingerprint_sha256: sourceFingerprint, sources: manifest.sources.map((item) => ({ path: item.path, file_sha256: item.file_sha256, applied_to: item.applied_to })) },
    resolved_requirements: requirements,
    generation_contract: {
      article_id: articleId, profile_id: PROFILE_ID, source_fingerprint_sha256: sourceFingerprint, approved_text: { title: approvedTitle }, dimensions: { width: 1280, height: 670 },
      reference_assets: [{ asset_id: master.asset_id, version: master.version, logical_locator: master.canonical_locator, manifest_locator: master.manifest_locator, sha256: master.actual_sha256, expected_sha256: master.expected_sha256, actual_sha256: master.actual_sha256, dimensions: { width: master.width, height: master.height }, provenance: master.provenance }],
      contract_identity_sha256: canonicalSha256(contractPayload), request_identity_sha256: canonicalSha256(toolRequest), invocation_arguments_sha256: canonicalSha256(invocationArguments),
      requirement_ids: mandatoryIds, creative_direction: [], inspection_capability: 'ai-visual-inspection', max_automatic_retries: 2,
      destination: 'NOTE_FINAL_REVIEW_PACKAGE', purpose: 'NOTE_HEADER_ASSET_PRODUCTION'
    },
    tool_route: { tool: 'image_gen.imagegen', capability: 'image-generation', allowed: true, rationale: 'validated Cloud Work visual production phase' },
    tool_request: toolRequest,
    preflight: { tool_route_check: true, contract_completeness_check: true, prompt_assembly_check: true, exact_text_check: true, negative_constraints_check: true, reference_asset_check: true, source_fingerprint_check: true, result: 'PASS' },
    runtime: { environment: 'cloud-work', implementation_id: CLOUD_IMPLEMENTATION, route: CLOUD_ROUTE, state: 'REQUEST_READY' },
    asset: { status: 'NOT_GENERATED', retry_count: 0, provenance: '' }, asset_qa: { performed: false, result: 'NOT_RUN', checks: [] },
    transition: { requested_target: 'TOOL_INVOCATION_PENDING', stop_reason: '' }
  };
  await validateVisualRecord({ repositoryRoot: root, record });
  const output = path.resolve(outputDirectory);
  const recordPath = path.join(output, 'visual-generation-record.json');
  const argumentsPath = path.join(output, 'imagegen-arguments.json');
  await writeImmutableJson(recordPath, record, 'VISUAL_RECORD_IMMUTABLE_CONFLICT');
  await writeImmutableJson(argumentsPath, invocationArguments, 'IMAGEGEN_ARGUMENTS_IMMUTABLE_CONFLICT');
  return { result: 'PASS', state: 'TOOL_INVOCATION_PENDING', record_path: recordPath, arguments_path: argumentsPath, contract_identity_sha256: record.generation_contract.contract_identity_sha256, invocation_arguments_sha256: record.generation_contract.invocation_arguments_sha256, master_path: master.actual_path };
}

export async function bindRuntime({ repositoryRoot, recordPath, argumentsPath, toolEventPath, outputPath }) {
  const record = await readJson(recordPath, 'VISUAL_RECORD_INVALID');
  await validateVisualRecord({ repositoryRoot, record });
  const args = await readJson(argumentsPath, 'IMAGEGEN_ARGUMENTS_INVALID');
  const expectedArgs = { prompt: record.tool_request.prompt, referenced_image_paths: record.tool_request.referenced_image_paths };
  requireValue(canonicalSha256(args) === canonicalSha256(expectedArgs), 'CLOUD_WORK_REQUEST_MISMATCH');
  const event = await readJson(toolEventPath, 'CLOUD_WORK_TOOL_EVENT_INVALID');
  exactKeys(event, ['schema_version','evidence_origin','environment','event_id','task_id','production_version','contract_identity_sha256','tool','invoked_at','completed_at','arguments','arguments_sha256','generated_asset'], ['schema_version','evidence_origin','environment','event_id','task_id','production_version','contract_identity_sha256','tool','invoked_at','completed_at','arguments','arguments_sha256','generated_asset'], 'CLOUD_WORK_TOOL_EVENT_SCHEMA_FAIL');
  exactKeys(event.arguments, ['prompt','referenced_image_paths'], ['prompt','referenced_image_paths'], 'CLOUD_WORK_TOOL_EVENT_SCHEMA_FAIL');
  exactKeys(event.generated_asset, ['local_path','sha256'], ['local_path','sha256','tool_output_locator'], 'CLOUD_WORK_TOOL_EVENT_SCHEMA_FAIL');
  requireValue(event.schema_version === 'cloud-work-image-generation-event/v1' && event.evidence_origin === 'current-task-cloud-work-tool-event' && event.environment === 'cloud-work', 'CLOUD_WORK_TOOL_EVENT_ORIGIN_INVALID');
  requireValue(event.task_id === record.task_id && event.production_version === record.production_version && event.contract_identity_sha256 === record.generation_contract.contract_identity_sha256, 'CLOUD_WORK_TOOL_EVENT_CONTRACT_MISMATCH');
  requireValue(event.tool === 'image_gen.imagegen' && event.event_id, 'CLOUD_WORK_TOOL_EVENT_TOOL_MISMATCH');
  requireValue(iso(event.invoked_at, 'CLOUD_WORK_TOOL_EVENT_TIME_INVALID') <= iso(event.completed_at, 'CLOUD_WORK_TOOL_EVENT_TIME_INVALID'), 'CLOUD_WORK_TOOL_EVENT_TIME_INVALID');
  const argsHash = canonicalSha256(args);
  requireValue(event.arguments_sha256 === argsHash && canonicalSha256(event.arguments) === argsHash, 'CLOUD_WORK_TOOL_EVENT_REQUEST_MISMATCH');
  const assetPath = path.resolve(event.generated_asset?.local_path || '');
  requireValue(await fileSha256(assetPath) === event.generated_asset?.sha256, 'CLOUD_WORK_GENERATED_ASSET_SHA_MISMATCH');
  const dims = await pngDimensions(assetPath);
  requireValue(dims.width === 1280 && dims.height === 670, 'CLOUD_WORK_GENERATED_ASSET_DIMENSIONS_MISMATCH');
  const receipt = {
    schema_version: 'visual-runtime-receipt/v1', task_id: record.task_id, production_version: record.production_version,
    environment: 'cloud-work', implementation_id: CLOUD_IMPLEMENTATION, route: CLOUD_ROUTE,
    capabilities: { current_source_resolution: 'VERIFIED', repository_script_execution: 'VERIFIED', image_generation_tool: 'VERIFIED', asset_inspection: 'VERIFIED', client_visible_request_binding: 'VERIFIED', platform_tool_choice_control: 'UNAVAILABLE' },
    request_binding: { validated_request_sha256: record.generation_contract.request_identity_sha256, actual_request_sha256: argsHash, match: true },
    tool_event_binding: { event_id: event.event_id, event_sha256: await fileSha256(toolEventPath), evidence_origin: event.evidence_origin, tool: event.tool, contract_identity_sha256: event.contract_identity_sha256, invocation_arguments_sha256: argsHash, generated_asset_sha256: event.generated_asset.sha256 },
    boundary: { repository_enforcement_scope: 'client-visible-request', platform_enforced: false, acknowledged: true },
    evidence: ['Current-task Cloud Work tool event bound to exact invocation arguments', 'Repository Master bytes and generated output bytes rehashed by cross-platform validator'],
    result: 'REQUEST_BOUND', checked_at: new Date().toISOString()
  };
  await writeImmutableJson(path.resolve(outputPath), receipt, 'RUNTIME_RECEIPT_IMMUTABLE_CONFLICT');
  return { result: 'PASS', state: 'GENERATED_UNVERIFIED', receipt_path: path.resolve(outputPath), receipt_sha256: await fileSha256(outputPath), generated_asset_path: assetPath, generated_asset_sha256: event.generated_asset.sha256 };
}

async function validateCloudReceipt({ record, receipt, argumentsValue, toolEvent, receiptPath, toolEventPath }) {
  requireValue(receipt.schema_version === 'visual-runtime-receipt/v1' && receipt.environment === 'cloud-work' && receipt.implementation_id === CLOUD_IMPLEMENTATION && receipt.route === CLOUD_ROUTE && receipt.result === 'REQUEST_BOUND', 'FORMAL_HEADER_BRIDGE_ROUTE_MISSING');
  requireValue(receipt.request_binding.validated_request_sha256 === record.generation_contract.request_identity_sha256 && receipt.request_binding.actual_request_sha256 === canonicalSha256(argumentsValue) && receipt.request_binding.match === true, 'CLOUD_WORK_REQUEST_BINDING_MISMATCH');
  requireValue(receipt.tool_event_binding?.event_sha256 === await fileSha256(toolEventPath) && receipt.tool_event_binding?.event_id === toolEvent.event_id && receipt.tool_event_binding?.contract_identity_sha256 === record.generation_contract.contract_identity_sha256, 'CLOUD_WORK_TOOL_EVENT_BINDING_MISMATCH');
  requireValue(receipt.tool_event_binding?.invocation_arguments_sha256 === canonicalSha256(argumentsValue) && receipt.tool_event_binding?.generated_asset_sha256 === toolEvent.generated_asset.sha256, 'CLOUD_WORK_TOOL_EVENT_BINDING_MISMATCH');
  requireValue(receipt.boundary?.platform_enforced === false && receipt.boundary?.acknowledged === true, 'CLOUD_WORK_PLATFORM_BOUNDARY_NOT_ACKNOWLEDGED');
  return { receipt_sha256: await fileSha256(receiptPath), tool_event_sha256: await fileSha256(toolEventPath) };
}

export async function completeAssetQa({ repositoryRoot, recordPath, receiptPath, argumentsPath, toolEventPath, qaEvidencePath, outputPath, assetCanonicalPointer }) {
  const record = await readJson(recordPath, 'VISUAL_RECORD_INVALID');
  await validateVisualRecord({ repositoryRoot, record });
  const receipt = await readJson(receiptPath, 'RUNTIME_RECEIPT_INVALID');
  const args = await readJson(argumentsPath, 'IMAGEGEN_ARGUMENTS_INVALID');
  const event = await readJson(toolEventPath, 'CLOUD_WORK_TOOL_EVENT_INVALID');
  const binding = await validateCloudReceipt({ record, receipt, argumentsValue: args, toolEvent: event, receiptPath, toolEventPath });
  const qa = await readJson(qaEvidencePath, 'CLOUD_WORK_ASSET_QA_INVALID');
  exactKeys(qa, ['schema_version','evidence_origin','environment','inspection_tool','inspection_event_id','task_id','production_version','contract_identity_sha256','runtime_receipt_sha256','tool_event_sha256','asset_sha256','dimensions','checks','result','performed_at'], ['schema_version','evidence_origin','environment','inspection_tool','inspection_event_id','task_id','production_version','contract_identity_sha256','runtime_receipt_sha256','tool_event_sha256','asset_sha256','dimensions','checks','result','performed_at'], 'CLOUD_WORK_ASSET_QA_SCHEMA_FAIL');
  requireValue(qa.schema_version === 'cloud-work-header-asset-qa/v1' && qa.evidence_origin === 'current-task-image-inspection-tool-event' && qa.environment === 'cloud-work', 'CLOUD_WORK_ASSET_QA_ORIGIN_INVALID');
  requireValue(['view_image','platform-image-inspection'].includes(qa.inspection_tool) && qa.inspection_event_id, 'CLOUD_WORK_ASSET_QA_TOOL_INVALID');
  requireValue(qa.task_id === record.task_id && qa.production_version === record.production_version && qa.contract_identity_sha256 === record.generation_contract.contract_identity_sha256, 'CLOUD_WORK_ASSET_QA_CONTRACT_MISMATCH');
  requireValue(qa.runtime_receipt_sha256 === binding.receipt_sha256 && qa.tool_event_sha256 === binding.tool_event_sha256 && qa.asset_sha256 === event.generated_asset.sha256, 'CLOUD_WORK_ASSET_QA_BINDING_MISMATCH');
  requireValue(qa.dimensions?.width === 1280 && qa.dimensions?.height === 670 && qa.result === 'PASS', 'CLOUD_WORK_ASSET_QA_FAIL');
  requireValue(iso(qa.performed_at, 'CLOUD_WORK_ASSET_QA_TIME_INVALID') >= iso(event.completed_at, 'CLOUD_WORK_TOOL_EVENT_TIME_INVALID'), 'CLOUD_WORK_ASSET_QA_BEFORE_GENERATION');
  const checks = new Map((qa.checks || []).map((item) => [item.requirement_id, item]));
  const mandatory = record.resolved_requirements.filter((item) => ['MUST','MUST_NOT'].includes(item.level)).map((item) => item.id);
  for (const id of [...mandatory, 'dimensions']) requireValue(checks.get(id)?.result === 'PASS' && checks.get(id)?.evidence, 'CLOUD_WORK_ASSET_QA_MISSING_CHECK', id);
  const updated = structuredClone(record);
  const assetPath = path.resolve(event.generated_asset.local_path);
  updated.asset = { status: 'QA_PASS', retry_count: record.asset.retry_count || 0, provenance: `cloud-work-image-generation-event:${event.event_id}`, file: assetCanonicalPointer, local_path: assetPath, sha256: event.generated_asset.sha256, width: 1280, height: 670 };
  updated.asset_qa = { performed: true, result: 'PASS', evidence_origin: qa.evidence_origin, evidence_path: path.resolve(qaEvidencePath), evidence_sha256: await fileSha256(qaEvidencePath), checks: qa.checks };
  updated.runtime.state = 'ASSET_QA_PASS';
  updated.transition = { requested_target: 'HUMAN_REVIEW_CANDIDATE', stop_reason: '' };
  await validateVisualRecord({ repositoryRoot, record: updated, requireCandidate: true });
  await writeImmutableJson(path.resolve(outputPath), updated, 'VISUAL_QA_RECORD_IMMUTABLE_CONFLICT');
  return { result: 'PASS', state: 'HUMAN_REVIEW_CANDIDATE', record_path: path.resolve(outputPath), record_sha256: await fileSha256(outputPath), asset_sha256: updated.asset.sha256 };
}

function explicitHeaderApproval(statement) {
  return /^(?:ok|approved?|これでいい|これでok|承認|採用|この画像でいい|このheaderでいい)[!！。\s]*$/i.test(String(statement).trim());
}

function formalIdentity(formal) {
  const payload = {
    article_id: formal.article_id, approved_header_title: formal.approved_header_title,
    asset: { file: formal.asset.file, sha256: formal.asset.sha256.toLowerCase(), width: formal.asset.width, height: formal.asset.height, provenance: formal.asset.provenance },
    master_template: { asset_id: formal.master_template.asset_id, version: formal.master_template.version, canonical_locator: formal.master_template.canonical_locator, expected_sha256: formal.master_template.expected_sha256.toLowerCase(), actual_sha256: formal.master_template.actual_sha256.toLowerCase(), width: formal.master_template.width, height: formal.master_template.height, provenance: formal.master_template.provenance },
    generation_contract: { profile_id: formal.generation_contract.profile_id, production_version: formal.generation_contract.production_version, source_manifest_identity: formal.generation_contract.source_manifest_identity.toLowerCase(), visual_record_sha256: formal.generation_contract.visual_record_sha256.toLowerCase(), actual_tool_request_sha256: formal.generation_contract.actual_tool_request_sha256.toLowerCase(), request_identity_sha256: formal.generation_contract.request_identity_sha256.toLowerCase() },
    route_evidence: { implementation_id: formal.route_evidence.implementation_id, route: formal.route_evidence.route, runtime_receipt_sha256: formal.route_evidence.runtime_receipt_sha256.toLowerCase(), result: formal.route_evidence.result },
    asset_qa: { status: formal.asset_qa.status, visual_record_sha256: formal.asset_qa.visual_record_sha256.toLowerCase() },
    human_approval: { event_id: formal.human_approval.event_id, evidence_sha256: formal.human_approval.evidence_sha256.toLowerCase() }
  };
  const identity = canonicalSha256(payload);
  return { identity_sha256: identity, formal_asset_id: `FHA-${safeArticle(formal.article_id)}-${identity}` };
}

export async function validateFormalHeaderAsset({ repositoryRoot, formalAssetPath, expectedArticleId, expectedHeaderTitle, expectedHeaderPath, recordOnly = false }) {
  const formal = await readJson(formalAssetPath, 'FORMAL_HEADER_ASSET_INVALID');
  requireValue(formal.schema_version === 'note-formal-header-asset/v1' && formal.promotion_version === 'note-header-promotion/v1' && formal.state === 'FORMAL_HEADER_ASSET', 'FORMAL_HEADER_ASSET_SCHEMA_FAIL');
  const identity = formalIdentity(formal);
  requireValue(formal.formal_asset_id === identity.formal_asset_id && formal.identity_sha256 === identity.identity_sha256, 'FORMAL_HEADER_ASSET_IDENTITY_MISMATCH');
  if (expectedArticleId) requireValue(formal.article_id === expectedArticleId, 'FORMAL_HEADER_ARTICLE_ID_MISMATCH');
  if (expectedHeaderTitle) requireValue(formal.approved_header_title === expectedHeaderTitle, 'FORMAL_HEADER_TITLE_MISMATCH');
  const localRoute = formal.route_evidence?.implementation_id === 'repo-skill:visual-production-bridge/v1' && formal.route_evidence?.route === 'repository-skill-request-bound';
  const cloudRoute = formal.route_evidence?.implementation_id === CLOUD_IMPLEMENTATION && formal.route_evidence?.route === CLOUD_ROUTE;
  requireValue((localRoute || cloudRoute) && formal.route_evidence?.result === 'REQUEST_BOUND', 'FORMAL_HEADER_BRIDGE_ROUTE_MISSING');
  requireValue(formal.master_template?.asset_id === MASTER_ID && formal.master_template?.version === MASTER_VERSION && formal.master_template?.expected_sha256 === formal.master_template?.actual_sha256, 'FORMAL_HEADER_MASTER_BINDING_MISMATCH');
  requireValue(formal.generation_contract?.profile_id === PROFILE_ID && formal.asset_qa?.status === 'PASS' && formal.eligibility?.final_review_package === true && formal.eligibility?.direct_generation_retroactive_promotion === false, 'FORMAL_HEADER_ELIGIBILITY_INVALID');
  const canonicalMaster = repositoryPath(repositoryRoot, formal.master_template.canonical_locator);
  requireValue(await fileSha256(canonicalMaster) === formal.master_template.actual_sha256, 'FORMAL_HEADER_MASTER_BINDING_MISMATCH');
  const base = path.dirname(path.resolve(formalAssetPath));
  const evidencePath = (value) => path.isAbsolute(value) ? path.resolve(value) : path.resolve(base, value);
  const headerPath = expectedHeaderPath ? path.resolve(expectedHeaderPath) : evidencePath(formal.asset.local_path);
  requireValue(await fileSha256(headerPath) === formal.asset.sha256, 'FORMAL_HEADER_BYTES_MISMATCH');
  requireValue(await fileSha256(evidencePath(formal.generation_contract.visual_record_local_path)) === formal.generation_contract.visual_record_sha256, 'FORMAL_HEADER_VISUAL_RECORD_SHA_MISMATCH');
  requireValue(await fileSha256(evidencePath(formal.route_evidence.runtime_receipt_local_path)) === formal.route_evidence.runtime_receipt_sha256, 'FORMAL_HEADER_RUNTIME_RECEIPT_SHA_MISMATCH');
  requireValue(await fileSha256(evidencePath(formal.human_approval.evidence_local_path)) === formal.human_approval.evidence_sha256, 'FORMAL_HEADER_HUMAN_APPROVAL_SHA_MISMATCH');
  const dims = await pngDimensions(headerPath);
  requireValue(dims.width === 1280 && dims.height === 670, 'FORMAL_HEADER_DIMENSIONS_MISMATCH');
  if (!recordOnly) {
    const record = await readJson(evidencePath(formal.generation_contract.visual_record_local_path));
    await validateVisualRecord({ repositoryRoot, record, requireCandidate: true });
    requireValue(record.generation_contract.article_id === formal.article_id && record.generation_contract.approved_text.title === formal.approved_header_title, 'FORMAL_HEADER_CONTRACT_BINDING_MISMATCH');
  }
  return { result: 'PASS', state: 'FORMAL_HEADER_ASSET', formal_asset_id: formal.formal_asset_id, identity_sha256: formal.identity_sha256, header_sha256: formal.asset.sha256 };
}

export async function promoteFormalHeader({ repositoryRoot, visualRecordPath, runtimeReceiptPath, argumentsPath, toolEventPath, generatedAssetPath, assetCanonicalPointer, humanApprovalPath, profileSourcePath, outputPath }) {
  const record = await readJson(visualRecordPath, 'VISUAL_RECORD_INVALID');
  await validateVisualRecord({ repositoryRoot, record, requireCandidate: true });
  const receipt = await readJson(runtimeReceiptPath, 'RUNTIME_RECEIPT_INVALID');
  const args = await readJson(argumentsPath, 'IMAGEGEN_ARGUMENTS_INVALID');
  const event = await readJson(toolEventPath, 'CLOUD_WORK_TOOL_EVENT_INVALID');
  await validateCloudReceipt({ record, receipt, argumentsValue: args, toolEvent: event, receiptPath: runtimeReceiptPath, toolEventPath });
  const approval = await readJson(humanApprovalPath, 'HEADER_HUMAN_APPROVAL_INVALID');
  exactKeys(approval, ['schema_version','event_id','actor_type','evidence_origin','occurred_at','statement','context'], ['schema_version','event_id','actor_type','evidence_origin','occurred_at','statement','context'], 'HEADER_HUMAN_APPROVAL_SCHEMA_FAIL');
  exactKeys(approval.context, ['stage','presented_at','article_id','approved_header_title','generated_asset_sha256','visual_record_sha256','runtime_receipt_sha256','actual_tool_request_sha256','destination','purpose'], ['stage','presented_at','article_id','approved_header_title','generated_asset_sha256','visual_record_sha256','runtime_receipt_sha256','actual_tool_request_sha256','destination','purpose'], 'HEADER_HUMAN_APPROVAL_SCHEMA_FAIL');
  requireValue(approval.schema_version === 'note-header-human-approval/v1' && approval.actor_type === 'human' && approval.evidence_origin === 'human-response-event', 'HEADER_HUMAN_APPROVAL_SCHEMA_FAIL');
  requireValue(explicitHeaderApproval(approval.statement), 'HEADER_HUMAN_APPROVAL_NOT_EXPLICIT');
  const presentedAt = iso(approval.context?.presented_at, 'HEADER_HUMAN_APPROVAL_TIME_INVALID');
  requireValue(iso(approval.occurred_at, 'HEADER_HUMAN_APPROVAL_TIME_INVALID') >= presentedAt, 'HEADER_HUMAN_APPROVAL_BEFORE_PRESENTATION');
  const qaEvidencePath = path.resolve(record.asset_qa.evidence_path || '');
  requireValue(await fileSha256(qaEvidencePath) === record.asset_qa.evidence_sha256, 'FORMAL_HEADER_ASSET_QA_EVIDENCE_MISMATCH');
  const qaEvidence = await readJson(qaEvidencePath, 'CLOUD_WORK_ASSET_QA_INVALID');
  requireValue(presentedAt >= iso(qaEvidence.performed_at, 'CLOUD_WORK_ASSET_QA_TIME_INVALID'), 'HEADER_CANDIDATE_PRESENTED_BEFORE_QA');
  const assetPath = path.resolve(generatedAssetPath);
  const assetSha = await fileSha256(assetPath);
  const visualSha = await fileSha256(visualRecordPath);
  const receiptSha = await fileSha256(runtimeReceiptPath);
  const approvalSha = await fileSha256(humanApprovalPath);
  const argsHash = canonicalSha256(args);
  const context = approval.context || {};
  for (const [actual, expected, code] of [
    [context.article_id, record.generation_contract.article_id, 'HEADER_HUMAN_APPROVAL_ARTICLE_MISMATCH'],
    [context.approved_header_title, record.generation_contract.approved_text.title, 'HEADER_HUMAN_APPROVAL_TITLE_MISMATCH'],
    [context.generated_asset_sha256, assetSha, 'HEADER_HUMAN_APPROVAL_ASSET_SHA_MISMATCH'],
    [context.visual_record_sha256, visualSha, 'HEADER_HUMAN_APPROVAL_VISUAL_RECORD_SHA_MISMATCH'],
    [context.runtime_receipt_sha256, receiptSha, 'HEADER_HUMAN_APPROVAL_RUNTIME_RECEIPT_SHA_MISMATCH'],
    [context.actual_tool_request_sha256, argsHash, 'HEADER_HUMAN_APPROVAL_REQUEST_SHA_MISMATCH'],
    [context.destination, 'NOTE_FINAL_REVIEW_PACKAGE', 'HEADER_HUMAN_APPROVAL_DESTINATION_MISMATCH'],
    [context.purpose, 'NOTE_HEADER_ASSET_PROMOTION', 'HEADER_HUMAN_APPROVAL_PURPOSE_MISMATCH']
  ]) requireValue(actual === expected, code);
  requireValue(record.asset.sha256 === assetSha && record.asset.file === assetCanonicalPointer, 'FORMAL_HEADER_GENERATED_ASSET_MISMATCH');
  const master = await resolveMaster({ repositoryRoot, profileSourcePath });
  const formal = {
    schema_version: 'note-formal-header-asset/v1', promotion_version: 'note-header-promotion/v1', state: 'FORMAL_HEADER_ASSET', formal_asset_id: '', identity_sha256: '',
    article_id: record.generation_contract.article_id, approved_header_title: record.generation_contract.approved_text.title,
    asset: { file: assetCanonicalPointer, local_path: assetPath, sha256: assetSha, width: 1280, height: 670, provenance: record.asset.provenance },
    master_template: { asset_id: master.asset_id, version: master.version, canonical_locator: master.canonical_locator, expected_sha256: master.expected_sha256, actual_sha256: master.actual_sha256, width: master.width, height: master.height, provenance: master.provenance },
    generation_contract: { profile_id: PROFILE_ID, production_version: record.production_version, source_manifest_identity: record.source_manifest.fingerprint_sha256, visual_record_sha256: visualSha, visual_record_local_path: path.resolve(visualRecordPath), actual_tool_request_sha256: argsHash, actual_tool_request_local_path: path.resolve(argumentsPath), request_identity_sha256: record.generation_contract.request_identity_sha256, profile_source_local_path: path.resolve(profileSourcePath), master_asset_local_path: master.actual_path },
    route_evidence: { implementation_id: CLOUD_IMPLEMENTATION, route: CLOUD_ROUTE, runtime_receipt_sha256: receiptSha, runtime_receipt_local_path: path.resolve(runtimeReceiptPath), result: 'REQUEST_BOUND' },
    asset_qa: { status: 'PASS', visual_record_sha256: visualSha },
    human_approval: { event_id: approval.event_id, evidence_sha256: approvalSha, evidence_local_path: path.resolve(humanApprovalPath) },
    eligibility: { final_review_package: true, direct_generation_retroactive_promotion: false }
  };
  Object.assign(formal, formalIdentity(formal));
  await writeImmutableJson(path.resolve(outputPath), formal, 'FORMAL_HEADER_ASSET_IMMUTABLE_CONFLICT');
  await validateFormalHeaderAsset({ repositoryRoot, formalAssetPath: outputPath, expectedArticleId: formal.article_id, expectedHeaderTitle: formal.approved_header_title, expectedHeaderPath: assetPath });
  return { result: 'PASS', state: 'FORMAL_HEADER_ASSET', formal_asset_id: formal.formal_asset_id, identity_sha256: formal.identity_sha256, output_path: path.resolve(outputPath) };
}

function parseArgs(argv) {
  const result = { _: [] };
  for (let index = 0; index < argv.length; index += 1) {
    const item = argv[index];
    if (!item.startsWith('--')) result._.push(item);
    else { const key = item.slice(2); const value = argv[index + 1]; requireValue(value && !value.startsWith('--'), 'ARGUMENT_VALUE_REQUIRED', key); result[key] = value; index += 1; }
  }
  return result;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const command = args._[0];
  const common = { repositoryRoot: path.resolve(args['repository-root'] || '.') };
  let result;
  if (command === 'prepare') result = await prepareGeneration({ ...common, sourceManifestPath: path.resolve(args['source-manifest']), profileSourcePath: path.resolve(args['profile-source']), taskId: args['task-id'], articleId: args['article-id'], productionVersion: args['production-version'], approvedTitle: args.title, outputDirectory: path.resolve(args['output-directory']) });
  else if (command === 'bind-runtime') result = await bindRuntime({ ...common, recordPath: path.resolve(args.record), argumentsPath: path.resolve(args.arguments), toolEventPath: path.resolve(args['tool-event']), outputPath: path.resolve(args.output) });
  else if (command === 'complete-qa') result = await completeAssetQa({ ...common, recordPath: path.resolve(args.record), receiptPath: path.resolve(args.receipt), argumentsPath: path.resolve(args.arguments), toolEventPath: path.resolve(args['tool-event']), qaEvidencePath: path.resolve(args['qa-evidence']), outputPath: path.resolve(args.output), assetCanonicalPointer: args['asset-canonical-pointer'] });
  else if (command === 'promote') result = await promoteFormalHeader({ ...common, visualRecordPath: path.resolve(args.record), runtimeReceiptPath: path.resolve(args.receipt), argumentsPath: path.resolve(args.arguments), toolEventPath: path.resolve(args['tool-event']), generatedAssetPath: path.resolve(args.asset), assetCanonicalPointer: args['asset-canonical-pointer'], humanApprovalPath: path.resolve(args.approval), profileSourcePath: path.resolve(args['profile-source']), outputPath: path.resolve(args.output) });
  else fail('CLOUD_WORK_HEADER_BRIDGE_USAGE', 'prepare|bind-runtime|complete-qa|promote');
  console.log(JSON.stringify(result));
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main().catch((error) => { console.error(error.message); process.exitCode = 1; });

export const constants = { MASTER_ID, MASTER_VERSION, PROFILE_ID, CLOUD_IMPLEMENTATION, CLOUD_ROUTE, CANONICAL_HEADER_IDS };
