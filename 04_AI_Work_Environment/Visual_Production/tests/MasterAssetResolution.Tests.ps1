$repositoryRoot = Resolve-Path (Join-Path $PSScriptRoot '../../..')
$profilePath = Join-Path $repositoryRoot '07_Note_Production/00_note制作・公開システム.md'
$assetPath = Join-Path $repositoryRoot '04_AI_Work_Environment/Visual_Production/assets/NOTE_HEADER_MASTER_TEMPLATE_v1.0.png'
$manifestPath = Join-Path $repositoryRoot '04_AI_Work_Environment/Visual_Production/assets/NOTE_HEADER_MASTER_TEMPLATE_v1.0.json'
$schemaPath = Join-Path $repositoryRoot '04_AI_Work_Environment/Visual_Production/schemas/note_header_master_asset.schema.json'
Import-Module (Join-Path $PSScriptRoot '../scripts/NoteHeaderRouting.psm1') -Force

Describe 'Repository canonical note Header Master' {
    It 'exists with a valid manifest in the Repository' {
        Test-Path -LiteralPath $assetPath -PathType Leaf | Should Be $true
        Test-Json -LiteralPath $manifestPath -SchemaFile $schemaPath | Should Be $true
    }

    It 'matches the canonical SHA-256 and dimensions' {
        (Get-NoteHeaderFileSha256 $assetPath) | Should Be '579aecaeb724228b86088445ffd3dc9d424a43757169c85f2f6149944beafc13'
        $dimensions=Get-NoteHeaderPngDimensions $assetPath
        $dimensions.width | Should Be 1280
        $dimensions.height | Should Be 670
    }

    It 'resolves the Master using Repository Current Sources only' {
        $result=Resolve-NoteHeaderMaster -ProfileSourcePath $profilePath -ProfileId 'aidaily-header-v1'
        $result.actual_path | Should Be ([IO.Path]::GetFullPath($assetPath))
        $result.manifest_path | Should Be ([IO.Path]::GetFullPath($manifestPath))
        $result.actual_sha256 | Should Be $result.expected_sha256
    }

    It 'rejects an external path even when supplied as a Master candidate' {
        $external=Join-Path $TestDrive 'master.png'; Copy-Item -LiteralPath $assetPath -Destination $external
        $threw=$false; try { Resolve-NoteHeaderMaster -ProfileSourcePath $profilePath -ProfileId 'aidaily-header-v1' -MasterAssetPath $external | Out-Null } catch { $threw=$true }
        $threw | Should Be $true
    }
}
