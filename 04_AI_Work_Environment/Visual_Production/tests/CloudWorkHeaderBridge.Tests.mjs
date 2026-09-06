import test from 'node:test';
import assert from 'node:assert/strict';
import { promises as fs } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildSourceManifest, canonicalSha256, fileSha256 } from '../../Source_Resolution/scripts/source-resolution.mjs';
import { bindRuntime, completeAssetQa, constants, normalizeGeneratedAsset, prepareGeneration, promoteFormalHeader, validateVisualRecord } from '../scripts/cloud-work-header-bridge.mjs';
import { decodePng, encodeRgbaPng } from '../scripts/deterministic-png-normalizer.mjs';
import { compileFinalReviewPackage } from '../../../07_Note_Production/Publication_Approval/scripts/final-review-package-compiler.mjs';

const repositoryRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../..');
const profileSource = path.join(repositoryRoot, '07_Note_Production/00_note制作・公開システム.md');
const OBSERVED_PRODUCTION_RAW_SHA256 = '40690887aec9223c8e78a71efd5847fba023f348dadae3dce9c8a2c705c5ea5c';

function rawFixturePng(width = 1734, height = 907) {
  const rgba = Buffer.alloc(width * height * 4);
  for (let y = 0; y < height; y += 1) for (let x = 0; x < width; x += 1) {
    const offset = (y * width + x) * 4;
    rgba[offset] = x % 256; rgba[offset + 1] = y % 256; rgba[offset + 2] = (x + y) % 256; rgba[offset + 3] = 255;
  }
  return encodeRgbaPng({ width, height, rgba });
}

async function writeJson(file, value) { await fs.writeFile(file, `${JSON.stringify(value, null, 2)}\n`, 'utf8'); return file; }
async function expectReject(action, pattern) { await assert.rejects(action, pattern); }

async function setup() {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), 'cloud-header-bridge-'));
  const taskId = 'CW-HEADER-E2E-001';
  const articleId = 'AIDAILY-TEST-CLOUD';
  const productionVersion = 'H1';
  const title = '「休む」が下手な私たちへ';
  const manifest = await buildSourceManifest({ repositoryRoot, taskId, productionVersion, responsibilityRoots: ['04_AI_Work_Environment/Source_Resolution','04_AI_Work_Environment/Visual_Production','07_Note_Production'], requiredPaths: [
    'REPOSITORY_RULES.md','AI_PRODUCTION_PIPELINE.md','04_AI_Work_Environment/Source_Resolution/README.md','04_AI_Work_Environment/Visual_Production/README.md',
    '07_Note_Production/00_note制作・公開システム.md','07_Note_Production/README.md','07_Note_Production/Publication_Approval/README.md'
  ] });
  const manifestPath = await writeJson(path.join(root, 'source-manifest.json'), manifest);
  const prepared = await prepareGeneration({ repositoryRoot, sourceManifestPath: manifestPath, profileSourcePath: profileSource, taskId, articleId, productionVersion, approvedTitle: title, outputDirectory: root });
  const record = JSON.parse(await fs.readFile(prepared.record_path, 'utf8'));
  const args = JSON.parse(await fs.readFile(prepared.arguments_path, 'utf8'));
  const rawAssetPath = path.join(root, 'header.raw.png');
  await fs.writeFile(rawAssetPath, rawFixturePng());
  const toolEvent = {
    schema_version: 'cloud-work-image-generation-event/v2', evidence_origin: 'current-task-cloud-work-tool-event', environment: 'cloud-work', event_id: 'CW-TOOL-001',
    task_id: taskId, production_version: productionVersion, contract_identity_sha256: record.generation_contract.contract_identity_sha256, tool: 'image_gen.imagegen',
    invoked_at: '2026-09-07T01:00:00.000Z', completed_at: '2026-09-07T01:01:00.000Z', arguments: args, arguments_sha256: canonicalSha256(args),
    generated_asset: { local_path: rawAssetPath, sha256: await fileSha256(rawAssetPath), tool_output_locator: 'current-task:imagegen-result-001', dimensions: { width: 1734, height: 907 } }
  };
  const toolEventPath = await writeJson(path.join(root, 'tool-event.json'), toolEvent);
  return { root, taskId, articleId, productionVersion, title, manifestPath, prepared, record, args, rawAssetPath, toolEvent, toolEventPath };
}

test('Cloud Work Header bridge acceptance and negative cases', async (t) => {
  const context = await setup();
  await t.test('Repository Master is resolved from Current Source with measured SHA and dimensions', async () => {
    assert.equal(context.record.generation_contract.reference_assets[0].actual_sha256, '579aecaeb724228b86088445ffd3dc9d424a43757169c85f2f6149944beafc13');
    assert.deepEqual(context.record.generation_contract.reference_assets[0].dimensions, { width: 1280, height: 670 });
    assert.equal(context.record.runtime.environment, 'cloud-work');
  });

  await t.test('direct generation without current-task Tool event fails', async () => {
    await expectReject(() => bindRuntime({ repositoryRoot, recordPath: context.prepared.record_path, argumentsPath: context.prepared.arguments_path, toolEventPath: path.join(context.root, 'missing-event.json'), outputPath: path.join(context.root, 'bad-receipt.json') }), /CLOUD_WORK_TOOL_EVENT_INVALID/);
  });

  await t.test('Master reference omission fails', async () => {
    const bad = structuredClone(context.record); bad.tool_request.referenced_image_paths = [];
    await expectReject(() => validateVisualRecord({ repositoryRoot, record: bad }), /Master reference missing/);
  });

  await t.test('Master SHA mismatch fails', async () => {
    const bad = structuredClone(context.record); bad.generation_contract.reference_assets[0].actual_sha256 = '0'.repeat(64);
    await expectReject(() => validateVisualRecord({ repositoryRoot, record: bad }), /Master SHA mismatch/);
  });

  await t.test('title or prompt alteration at actual invocation fails', async () => {
    const badArgs = structuredClone(context.args); badArgs.prompt = badArgs.prompt.replace(context.title, '改変タイトル');
    const badArgsPath = await writeJson(path.join(context.root, 'bad-title-args.json'), badArgs);
    await expectReject(() => bindRuntime({ repositoryRoot, recordPath: context.prepared.record_path, argumentsPath: badArgsPath, toolEventPath: context.toolEventPath, outputPath: path.join(context.root, 'bad-title-receipt.json') }), /CLOUD_WORK_REQUEST_MISMATCH/);
  });

  await t.test('self-described or wrong-origin Tool event fails', async () => {
    const badEvent = structuredClone(context.toolEvent); badEvent.evidence_origin = 'agent-self-report';
    const badEventPath = await writeJson(path.join(context.root, 'bad-origin-event.json'), badEvent);
    await expectReject(() => bindRuntime({ repositoryRoot, recordPath: context.prepared.record_path, argumentsPath: context.prepared.arguments_path, toolEventPath: badEventPath, outputPath: path.join(context.root, 'bad-origin-receipt.json') }), /CLOUD_WORK_TOOL_EVENT_ORIGIN_INVALID/);
  });

  const receiptPath = path.join(context.root, 'runtime-receipt.json');
  const bound = await bindRuntime({ repositoryRoot, recordPath: context.prepared.record_path, argumentsPath: context.prepared.arguments_path, toolEventPath: context.toolEventPath, outputPath: receiptPath });
  await t.test('1734x907 native Raw Asset is bound unchanged instead of rejected', async () => {
    assert.equal(bound.state, 'RAW_GENERATED_UNVERIFIED');
    assert.deepEqual(bound.raw_dimensions, { width: 1734, height: 907 });
    assert.equal(bound.raw_asset_sha256, context.toolEvent.generated_asset.sha256);
    assert.match(OBSERVED_PRODUCTION_RAW_SHA256, /^[0-9a-f]{64}$/);
  });

  await t.test('declared Raw dimensions that differ from actual bytes fail', async () => {
    const badEvent = structuredClone(context.toolEvent); badEvent.generated_asset.dimensions.width = 1280;
    const badEventPath = await writeJson(path.join(context.root, 'bad-raw-dimensions-event.json'), badEvent);
    await expectReject(() => bindRuntime({ repositoryRoot, recordPath: context.prepared.record_path, argumentsPath: context.prepared.arguments_path, toolEventPath: badEventPath, outputPath: path.join(context.root, 'bad-raw-dimensions-receipt.json') }), /CLOUD_WORK_GENERATED_ASSET_DIMENSIONS_MISMATCH/);
  });

  const receiptSha = await fileSha256(receiptPath);
  const toolEventSha = await fileSha256(context.toolEventPath);
  const rawShaBefore = await fileSha256(context.rawAssetPath);
  const normalizedAssetPath = path.join(context.root, 'header.normalized.png');
  const normalizationPath = path.join(context.root, 'normalization-evidence.json');
  const normalized = await normalizeGeneratedAsset({ repositoryRoot, recordPath: context.prepared.record_path, receiptPath, argumentsPath: context.prepared.arguments_path, toolEventPath: context.toolEventPath, outputAssetPath: normalizedAssetPath, outputEvidencePath: normalizationPath, eventId: 'CW-NORMALIZE-001', startedAt: '2026-09-07T01:01:10.000Z', completedAt: '2026-09-07T01:01:20.000Z' });

  await t.test('1734x907 Raw Asset normalizes deterministically to a distinct 1280x670 Candidate', async () => {
    assert.equal(await fileSha256(context.rawAssetPath), rawShaBefore);
    assert.deepEqual(decodePng(await fs.readFile(normalizedAssetPath)).width, 1280);
    assert.deepEqual(decodePng(await fs.readFile(normalizedAssetPath)).height, 670);
    assert.notEqual(normalized.normalized_asset_sha256, rawShaBefore);
    assert.equal(normalized.normalized_asset_sha256, 'f64b8d52f688987a71df4024b22756df6bfcf3a6be799994196fbf79b7dc21c0');
    const secondPath = path.join(context.root, 'header.normalized.second.png');
    const secondEvidence = path.join(context.root, 'normalization-evidence.second.json');
    const second = await normalizeGeneratedAsset({ repositoryRoot, recordPath: context.prepared.record_path, receiptPath, argumentsPath: context.prepared.arguments_path, toolEventPath: context.toolEventPath, outputAssetPath: secondPath, outputEvidencePath: secondEvidence, eventId: 'CW-NORMALIZE-001', startedAt: '2026-09-07T01:01:10.000Z', completedAt: '2026-09-07T01:01:20.000Z' });
    assert.equal(second.normalized_asset_sha256, normalized.normalized_asset_sha256);
    assert.equal(second.normalization_identity_sha256, normalized.normalization_identity_sha256);
  });

  const mandatory = context.record.resolved_requirements.filter((item) => ['MUST','MUST_NOT'].includes(item.level)).map((item) => item.id);
  const qa = {
    schema_version: 'cloud-work-header-asset-qa/v2', evidence_origin: 'current-task-image-inspection-tool-event', environment: 'cloud-work', inspection_tool: 'view_image', inspection_event_id: 'CW-VIEW-001',
    task_id: context.taskId, production_version: context.productionVersion, contract_identity_sha256: context.record.generation_contract.contract_identity_sha256,
    runtime_receipt_sha256: receiptSha, tool_event_sha256: toolEventSha, normalization_event_sha256: await fileSha256(normalizationPath), raw_asset_sha256: rawShaBefore, asset_sha256: await fileSha256(normalizedAssetPath), dimensions: { width: 1280, height: 670 },
    checks: [...mandatory, 'dimensions'].map((requirement_id) => ({ requirement_id, result: 'PASS', evidence: `current-task visual inspection verified ${requirement_id}` })), result: 'PASS', performed_at: '2026-09-07T01:02:00.000Z'
  };

  await t.test('Asset QA without Normalization Evidence fails', async () => {
    await expectReject(() => completeAssetQa({ repositoryRoot, recordPath: context.prepared.record_path, receiptPath, argumentsPath: context.prepared.arguments_path, toolEventPath: context.toolEventPath, normalizationEvidencePath: path.join(context.root, 'missing-normalization.json'), qaEvidencePath: path.join(context.root, 'not-used.json'), outputPath: path.join(context.root, 'missing-normalization-record.json'), assetCanonicalPointer: 'AIDAILY-TEST-CLOUD_Header.png' }), /HEADER_NORMALIZATION_EVIDENCE_INVALID/);
  });

  await t.test('tampered Normalization Evidence fails before Asset QA', async () => {
    const badNormalization = JSON.parse(await fs.readFile(normalizationPath, 'utf8'));
    badNormalization.input.sha256 = '0'.repeat(64);
    const badNormalizationPath = await writeJson(path.join(context.root, 'bad-normalization.json'), badNormalization);
    const qaPathForTamper = await writeJson(path.join(context.root, 'qa-for-tamper.json'), qa);
    await expectReject(() => completeAssetQa({ repositoryRoot, recordPath: context.prepared.record_path, receiptPath, argumentsPath: context.prepared.arguments_path, toolEventPath: context.toolEventPath, normalizationEvidencePath: badNormalizationPath, qaEvidencePath: qaPathForTamper, outputPath: path.join(context.root, 'bad-normalization-record.json'), assetCanonicalPointer: 'AIDAILY-TEST-CLOUD_Header.png' }), /HEADER_NORMALIZATION_RAW_ASSET_BINDING_MISMATCH|HEADER_NORMALIZATION_IDENTITY_MISMATCH/);
  });

  await t.test('tampered Normalized Asset bytes fail before Asset QA', async () => {
    const tamperedAssetPath = path.join(context.root, 'header.normalized.tampered.png');
    const tamperedBytes = Buffer.from(await fs.readFile(normalizedAssetPath)); tamperedBytes[100] ^= 1;
    await fs.writeFile(tamperedAssetPath, tamperedBytes);
    const badNormalization = JSON.parse(await fs.readFile(normalizationPath, 'utf8'));
    badNormalization.output.local_path = tamperedAssetPath;
    const badNormalizationPath = await writeJson(path.join(context.root, 'bad-output-normalization.json'), badNormalization);
    const badQa = structuredClone(qa); badQa.normalization_event_sha256 = await fileSha256(badNormalizationPath);
    const badQaPath = await writeJson(path.join(context.root, 'bad-output-qa.json'), badQa);
    await expectReject(() => completeAssetQa({ repositoryRoot, recordPath: context.prepared.record_path, receiptPath, argumentsPath: context.prepared.arguments_path, toolEventPath: context.toolEventPath, normalizationEvidencePath: badNormalizationPath, qaEvidencePath: badQaPath, outputPath: path.join(context.root, 'bad-output-record.json'), assetCanonicalPointer: 'AIDAILY-TEST-CLOUD_Header.png' }), /HEADER_NORMALIZATION_OUTPUT_BYTES_MISMATCH/);
  });

  await t.test('missing Asset QA requirement fails', async () => {
    const badQa = structuredClone(qa); badQa.checks = badQa.checks.filter((item) => item.requirement_id !== 'title-exact');
    const badQaPath = await writeJson(path.join(context.root, 'bad-qa.json'), badQa);
    await expectReject(() => completeAssetQa({ repositoryRoot, recordPath: context.prepared.record_path, receiptPath, argumentsPath: context.prepared.arguments_path, toolEventPath: context.toolEventPath, normalizationEvidencePath: normalizationPath, qaEvidencePath: badQaPath, outputPath: path.join(context.root, 'bad-qa-record.json'), assetCanonicalPointer: 'AIDAILY-TEST-CLOUD_Header.png' }), /CLOUD_WORK_ASSET_QA_MISSING_CHECK/);
  });

  const qaPath = await writeJson(path.join(context.root, 'asset-qa.json'), qa);
  const qaRecordPath = path.join(context.root, 'visual-generation-record.qa.json');
  await completeAssetQa({ repositoryRoot, recordPath: context.prepared.record_path, receiptPath, argumentsPath: context.prepared.arguments_path, toolEventPath: context.toolEventPath, normalizationEvidencePath: normalizationPath, qaEvidencePath: qaPath, outputPath: qaRecordPath, assetCanonicalPointer: 'AIDAILY-TEST-CLOUD_Header.png' });
  const approval = {
    schema_version: 'note-header-human-approval/v1', event_id: 'HE-CLOUD-HEADER-001', actor_type: 'human', evidence_origin: 'human-response-event', occurred_at: '2026-09-07T01:04:00.000Z', statement: 'これでいい',
    context: { stage: 'HEADER_ASSET_CANDIDATE_PRESENTED', presented_at: '2026-09-07T01:03:00.000Z', article_id: context.articleId, approved_header_title: context.title, raw_asset_sha256: rawShaBefore, normalization_identity_sha256: normalized.normalization_identity_sha256, generated_asset_sha256: await fileSha256(normalizedAssetPath), visual_record_sha256: await fileSha256(qaRecordPath), runtime_receipt_sha256: receiptSha, actual_tool_request_sha256: canonicalSha256(context.args), destination: 'NOTE_FINAL_REVIEW_PACKAGE', purpose: 'NOTE_HEADER_ASSET_PROMOTION' }
  };

  await t.test('Human Approval from a different Article cannot be reused', async () => {
    const badApproval = structuredClone(approval); badApproval.context.article_id = 'AIDAILY-OTHER';
    const badApprovalPath = await writeJson(path.join(context.root, 'bad-approval.json'), badApproval);
    await expectReject(() => promoteFormalHeader({ repositoryRoot, visualRecordPath: qaRecordPath, runtimeReceiptPath: receiptPath, argumentsPath: context.prepared.arguments_path, toolEventPath: context.toolEventPath, normalizationEvidencePath: normalizationPath, generatedAssetPath: normalizedAssetPath, assetCanonicalPointer: 'AIDAILY-TEST-CLOUD_Header.png', humanApprovalPath: badApprovalPath, profileSourcePath: profileSource, outputPath: path.join(context.root, 'bad-formal.json') }), /HEADER_HUMAN_APPROVAL_ARTICLE_MISMATCH/);
  });

  await t.test('Human Approval for another Normalization identity cannot be reused', async () => {
    const badApproval = structuredClone(approval); badApproval.context.normalization_identity_sha256 = '0'.repeat(64);
    const badApprovalPath = await writeJson(path.join(context.root, 'bad-normalization-approval.json'), badApproval);
    await expectReject(() => promoteFormalHeader({ repositoryRoot, visualRecordPath: qaRecordPath, runtimeReceiptPath: receiptPath, argumentsPath: context.prepared.arguments_path, toolEventPath: context.toolEventPath, normalizationEvidencePath: normalizationPath, generatedAssetPath: normalizedAssetPath, assetCanonicalPointer: 'AIDAILY-TEST-CLOUD_Header.png', humanApprovalPath: badApprovalPath, profileSourcePath: profileSource, outputPath: path.join(context.root, 'bad-normalization-formal.json') }), /HEADER_HUMAN_APPROVAL_NORMALIZATION_MISMATCH/);
  });

  await t.test('complete Cloud Work chain reaches Formal Header and Final Review Package Compiler', async () => {
    const approvalPath = await writeJson(path.join(context.root, 'header-human-approval.json'), approval);
    const formalPath = path.join(context.root, 'formal-header-asset.json');
    const promoted = await promoteFormalHeader({ repositoryRoot, visualRecordPath: qaRecordPath, runtimeReceiptPath: receiptPath, argumentsPath: context.prepared.arguments_path, toolEventPath: context.toolEventPath, normalizationEvidencePath: normalizationPath, generatedAssetPath: normalizedAssetPath, assetCanonicalPointer: 'AIDAILY-TEST-CLOUD_Header.png', humanApprovalPath: approvalPath, profileSourcePath: profileSource, outputPath: formalPath });
    assert.equal(promoted.state, 'FORMAL_HEADER_ASSET');
    const bodyPath = path.join(context.root, 'body.md'); await fs.writeFile(bodyPath, '# D3\n\n本文です。\n', 'utf8');
    const marketingPath = path.join(context.root, 'marketing.json'); await writeJson(marketingPath, { result: 'PASS' });
    const input = {
      schema_version: 'note-final-review-package-input/v2', workflow_state: 'MARKETING_APPROVED', article_id: context.articleId, title: context.title,
      d3_body: { artifact_id: 'D3-CLOUD', file: 'body.md', local_path: bodyPath, sha256: await fileSha256(bodyPath) },
      marketing_review: { status: 'PASS', identity: 'MR-CLOUD-001', version: 'D3', evidence: { artifact_id: 'MR-EVIDENCE', file: 'marketing.json', local_path: marketingPath, sha256: await fileSha256(marketingPath) } },
      header: { asset_id: promoted.formal_asset_id, display_title: context.title, file: 'AIDAILY-TEST-CLOUD_Header.png', local_path: normalizedAssetPath, sha256: await fileSha256(normalizedAssetPath), formal_asset: { artifact_id: promoted.formal_asset_id, file: 'formal-header-asset.json', local_path: formalPath, sha256: await fileSha256(formalPath) }, asset_qa: { status: 'PASS', evidence: { artifact_id: 'HEADER-QA-CLOUD', file: 'visual-generation-record.qa.json', local_path: qaRecordPath, sha256: await fileSha256(qaRecordPath) } } },
      publication_conditions: { access_boundary: { mode: 'MEMBERSHIP', free_end_marker: '<!-- free-end -->', membership_start_marker: '<!-- membership-start -->' }, membership: { enabled: true, name: 'メンバーシップ', plan: 'standard' }, magazine: { enabled: true, name: 'AIDAILY' }, price: { currency: 'JPY', amount: 500 }, tags: ['AI','ケア'], other_conditions: ['コメント可'] },
      destination: { service: 'note', account_id: 'miku', publication_target: 'AIDAILY' }, purpose: 'NOTE_PUBLICATION',
      source_manifest: { manifest_id: 'SM-CLOUD-001', file: 'source-manifest.json', local_path: context.manifestPath, sha256: await fileSha256(context.manifestPath) }
    };
    const inputPath = await writeJson(path.join(context.root, 'final-review-input.json'), input);
    const compiled = await compileFinalReviewPackage({ repositoryRoot, inputPath, outputDirectory: path.join(context.root, 'final-review') });
    assert.equal(compiled.state, 'READY_FOR_FINAL_REVIEW');
    const packageValue = JSON.parse(await fs.readFile(compiled.package_path, 'utf8'));
    assert.equal(packageValue.header.route_evidence.implementation_id, constants.CLOUD_IMPLEMENTATION);
    assert.equal(packageValue.header.route_evidence.route, constants.CLOUD_ROUTE);
  });
});
