from __future__ import annotations

import json
import unittest
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class SkillPackageTests(unittest.TestCase):
    def test_manifest_matches_bundled_assets(self) -> None:
        manifest = json.loads((ROOT / "manifest.json").read_text(encoding="utf-8"))
        assets = manifest["bundled_assets"]
        for item in assets.values():
            bundle = ROOT / item["file"]
            self.assertTrue(bundle.is_file(), bundle)
            self.assertGreater(bundle.stat().st_size, 1000)
            with zipfile.ZipFile(bundle) as archive:
                names = set(archive.namelist())
                self.assertTrue(any(name.endswith("bundle.json") for name in names))
                self.assertTrue(any(name.endswith("pragma.yaml") for name in names))

    def test_required_entrypoints_and_reports_exist(self) -> None:
        for relative in (
            "SKILL.md",
            "README.md",
            "agents/interface.yaml",
            "evals/trigger_cases.json",
            "reports/skill-ir.json",
            "reports/trigger-eval.json",
            "scripts/install_pragma_agency.ps1",
            "scripts/verify_pragma_agency.ps1",
            "scripts/create_pragma_shortcut.ps1",
            "scripts/rollback_pragma_agency.ps1",
        ):
            self.assertTrue((ROOT / relative).is_file(), relative)

        trigger = json.loads((ROOT / "reports/trigger-eval.json").read_text(encoding="utf-8"))
        self.assertTrue(trigger["ok"])
        self.assertEqual(trigger["summary"]["total"], 11)
        self.assertEqual(trigger["summary"]["passed"], 11)

    def test_no_secret_like_environment_values_are_embedded(self) -> None:
        text = "\n".join(
            path.read_text(encoding="utf-8", errors="ignore")
            for path in (ROOT / "scripts").glob("*.ps1")
        )
        self.assertNotIn("OPENAI_API_KEY=", text)
        self.assertNotIn("Authorization: Bearer", text)


if __name__ == "__main__":
    unittest.main()
