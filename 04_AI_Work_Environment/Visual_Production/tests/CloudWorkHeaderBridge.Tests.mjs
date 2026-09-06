import test from 'node:test';
import assert from 'node:assert/strict';
import { promises as fs } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildSourceManifest, canonicalSha256, fileSha256 } from '../../Source_Resolution/scripts/source-resolution.mjs';
import { bindRuntime, completeAssetQa, constants, prepareGeneration, promoteFormalHeader, validateVisualRecord } from '../scripts/cloud-work-header-bridge.mjs';
import { compileFinalReviewPackage } from '../../../07_Note_Production/Publication_Approval/scripts/final-review-package-compiler.mjs';

const repositoryRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../..');
const profileSource = path.join(repositoryRoot, '07_Note_Production/00_note制作・公開システム.md');
const masterPath = path.join(repositoryRoot, '04_AI_Work_Environment/Visual_Production/assets/NOTE_HEADER_MASTER_TEMPLATE_v1.0.png');

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
  const assetPath = path.join(root, 'header.png');
  await fs.copyFile(masterPath, assetPath);
  const toolEvent = {
    schema_version: 'cloud-work-image-generation-event/v1', evidence_origin: 'current-task-cloud-work-tool-event', environment: 'cloud-work', event_id: 'CW-TOOL-001',
    task_id: taskId, production_version: productionVersion, contract_identity_sha256: record.generation_contract.contract_identity_sha256, tool: 'image_gen.imagegen',
    invoked_at: '2026-09-07T01:00:00.000Z', completed_at: '2026-09-07T01:01:00.000Z', arguments: args, arguments_sha256: canonicalSha256(args),
    generated_asset: { local_path: assetPath, sha256: await fileSha256(assetPath), tool_output_locator: 'current-task:imagegen-result-001' }
  };
  const toolEventPath = await writeJson(path.join(root, 'tool-event.json'), toolEvent);
  return { root, taskId, articleId, productionVersion, title, manifestPath, prepared, record, args, assetPath, toolEvent, toolEventPath };
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
  await bindRuntime({ repositoryRoot, recordPath: context.prepared.record_path, argumentsPath: context.prepared.arguments_path, toolEventPath: context.toolEventPath, outputPath: receiptPath });
  const receiptSha = await fileSha256(receiptPath);
  const toolEventSha = await fileSha256(context.toolEventPath);
  const mandatory = context.record.resolved_requirements.filter((item) => ['MUST','MUST_NOT'].includes(item.level)).map((item) => item.id);
  const qa = {
    schema_version: 'cloud-work-header-asset-qa/v1', evidence_origin: 'current-task-image-inspection-tool-event', environment: 'cloud-work', inspection_tool: 'view_image', inspection_event_id: 'CW-VIEW-001',
    task_id: context.taskId, production_version: context.productionVersion, contract_identity_sha256: context.record.generation_contract.contract_identity_sha256,
    runtime_receipt_sha256: receiptSha, tool_event_sha256: toolEventSha, asset_sha256: await fileSha256(context.assetPath), dimensions: { width: 1280, height: 670 },
    checks: [...mandatory, 'dimensions'].map((requirement_id) => ({ requirement_id, result: 'PASS', evidence: `current-task visual inspection verified ${requirement_id}` })), result: 'PASS', performed_at: '2026-09-07T01:02:00.000Z'
  };

  await t.test('missing Asset QA requirement fails', async () => {
    const badQa = structuredClone(qa); badQa.checks = badQa.checks.filter((item) => item.requirement_id !== 'title-exact');
    const badQaPath = await writeJson(path.join(context.root, 'bad-qa.json'), badQa);
    await expectReject(() => completeAssetQa({ repositoryRoot, recordPath: context.prepared.record_path, receiptPath, argumentsPath: context.prepared.arguments_path, toolEventPath: context.toolEventPath, qaEvidencePath: badQaPath, outputPath: path.join(context.root, 'bad-qa-record.json'), assetCanonicalPointer: 'AIDAILY-TEST-CLOUD_Header.png' }), /CLOUD_WORK_ASSET_QA_MISSING_CHECK/);
  });

  const qaPath = await writeJson(path.join(context.root, 'asset-qa.json'), qa);
  const qaRecordPath = path.join(context.root, 'visual-generation-record.qa.json');
  await completeAssetQa({ repositoryRoot, recordPath: context.prepared.record_path, receiptPath, argumentsPath: context.prepared.arguments_path, toolEventPath: context.toolEventPath, qaEvidencePath: qaPath, outputPath: qaRecordPath, assetCanonicalPointer: 'AIDAILY-TEST-CLOUD_Header.png' });
  const approval = {
    schema_version: 'note-header-human-approval/v1', event_id: 'HE-CLOUD-HEADER-001', actor_type: 'human', evidence_origin: 'human-response-event', occurred_at: '2026-09-07T01:04:00.000Z', statement: 'これでいい',
    context: { stage: 'HEADER_ASSET_CANDIDATE_PRESENTED', presented_at: '2026-09-07T01:03:00.000Z', article_id: context.articleId, approved_header_title: context.title, generated_asset_sha256: await fileSha256(context.assetPath), visual_record_sha256: await fileSha256(qaRecordPath), runtime_receipt_sha256: receiptSha, actual_tool_request_sha256: canonicalSha256(context.args), destination: 'NOTE_FINAL_REVIEW_PACKAGE', purpose: 'NOTE_HEADER_ASSET_PROMOTION' }
  };

  await t.test('Human Approval from a different Article cannot be reused', async () => {
    const badApproval = structuredClone(approval); badApproval.context.article_id = 'AIDAILY-OTHER';
    const badApprovalPath = await writeJson(path.join(context.root, 'bad-approval.json'), badApproval);
    await expectReject(() => promoteFormalHeader({ repositoryRoot, visualRecordPath: qaRecordPath, runtimeReceiptPath: receiptPath, argumentsPath: context.prepared.arguments_path, toolEventPath: context.toolEventPath, generatedAssetPath: context.assetPath, assetCanonicalPointer: 'AIDAILY-TEST-CLOUD_Header.png', humanApprovalPath: badApprovalPath, profileSourcePath: profileSource, outputPath: path.join(context.root, 'bad-formal.json') }), /HEADER_HUMAN_APPROVAL_ARTICLE_MISMATCH/);
  });

  await t.test('complete Cloud Work chain reaches Formal Header and Final Review Package Compiler', async () => {
    const approvalPath = await writeJson(path.join(context.root, 'header-human-approval.json'), approval);
    const formalPath = path.join(context.root, 'formal-header-asset.json');
    const promoted = await promoteFormalHeader({ repositoryRoot, visualRecordPath: qaRecordPath, runtimeReceiptPath: receiptPath, argumentsPath: context.prepared.arguments_path, toolEventPath: context.toolEventPath, generatedAssetPath: context.assetPath, assetCanonicalPointer: 'AIDAILY-TEST-CLOUD_Header.png', humanApprovalPath: approvalPath, profileSourcePath: profileSource, outputPath: formalPath });
    assert.equal(promoted.state, 'FORMAL_HEADER_ASSET');
    const bodyPath = path.join(context.root, 'body.md'); await fs.writeFile(bodyPath, '# D3\n\n本文です。\n', 'utf8');
    const marketingPath = path.join(context.root, 'marketing.json'); await writeJson(marketingPath, { result: 'PASS' });
    const input = {
      schema_version: 'note-final-review-package-input/v2', workflow_state: 'MARKETING_APPROVED', article_id: context.articleId, title: context.title,
      d3_body: { artifact_id: 'D3-CLOUD', file: 'body.md', local_path: bodyPath, sha256: await fileSha256(bodyPath) },
      marketing_review: { status: 'PASS', identity: 'MR-CLOUD-001', version: 'D3', evidence: { artifact_id: 'MR-EVIDENCE', file: 'marketing.json', local_path: marketingPath, sha256: await fileSha256(marketingPath) } },
      header: { asset_id: promoted.formal_asset_id, display_title: context.title, file: 'AIDAILY-TEST-CLOUD_Header.png', local_path: context.assetPath, sha256: await fileSha256(context.assetPath), formal_asset: { artifact_id: promoted.formal_asset_id, file: 'formal-header-asset.json', local_path: formalPath, sha256: await fileSha256(formalPath) }, asset_qa: { status: 'PASS', evidence: { artifact_id: 'HEADER-QA-CLOUD', file: 'visual-generation-record.qa.json', local_path: qaRecordPath, sha256: await fileSha256(qaRecordPath) } } },
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
