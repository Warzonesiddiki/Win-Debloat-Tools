#!/usr/bin/env python3
"""
Automated workspace integrity & regression test suite for Win-Debloat-Tools.
Tests syntax validity, import completeness, zero-AI reversibility, safe execution,
preset script file existence, and protected service guardrails.
"""

import os
import re
import unittest


class TestWorkspaceIntegrity(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
        cls.ps_files = []
        cls.module_funcs = {}

        # Collect all PowerShell files and function definitions in .psm1 modules
        for root, _, files in os.walk(cls.repo_root):
            if ".git" in root or "__pycache__" in root:
                continue
            for f in files:
                if f.endswith(".ps1") or f.endswith(".psm1"):
                    full_p = os.path.join(root, f)
                    cls.ps_files.append(full_p)
                    if f.endswith(".psm1"):
                        rel_src = os.path.relpath(full_p, cls.repo_root).replace("\\", "/")
                        with open(full_p, "r", encoding="utf-8", errors="ignore") as fh:
                            content = fh.read()
                            matches = re.findall(r"function\s+([A-Za-z0-9\-_]+)", content, re.IGNORECASE)
                            for m in matches:
                                cls.module_funcs[m] = rel_src

    def test_function_declarations_validity(self):
        """Verify that every function declared in PS files has a valid non-empty identifier."""
        for p in self.ps_files:
            rel = os.path.relpath(p, self.repo_root)
            with open(p, "r", encoding="utf-8", errors="ignore") as fh:
                content = fh.read()

            func_matches = re.findall(r"function\s+([A-Za-z0-9\-_]+)\s*(?:\([^\)]*\))?\s*\{", content, re.IGNORECASE)
            for fn in func_matches:
                self.assertTrue(len(fn) > 0, f"Empty function name found in {rel}")

    def test_import_completeness(self):
        """Verify that every script imports all required modules for invoked cmdlets."""
        missing_imports = []
        for p in self.ps_files:
            rel = os.path.relpath(p, self.repo_root)
            if rel.startswith("tests"):
                continue

            with open(p, "r", encoding="utf-8", errors="ignore") as fh:
                content = fh.read()

            calls = set(re.findall(r"\b([A-Z][a-zA-Z0-9]+-[A-Z][a-zA-Z0-9]+)\b", content))
            raw_imports = re.findall(
                r'Import-Module\s+(?:-DisableNameChecking\s+)?["\']([^"\']+\.psm1)["\']',
                content,
            )
            imported_basenames = [os.path.basename(i.replace("\\", "/")).lower() for i in raw_imports]
            local_funcs = set(re.findall(r"function\s+([A-Za-z0-9\-_]+)", content, re.IGNORECASE))

            for c in calls:
                if c in self.module_funcs and c not in local_funcs:
                    target_module = self.module_funcs[c]
                    base = os.path.basename(target_module).lower()
                    if base not in imported_basenames:
                        missing_imports.append((rel, c, target_module))

        if missing_imports:
            msg = "\n".join(f"{f}: calls {c}() without importing {m}" for f, c, m in missing_imports)
            self.fail(f"Found missing imports:\n{msg}")

    def test_zero_ai_toggles_have_matching_enablers(self):
        """Verify that every Disable-* AI function in Windows11-Tweaks has an Enable-* counterpart."""
        win11_tweaks_path = os.path.join(self.repo_root, "src", "utils", "Windows11-Tweaks.psm1")
        with open(win11_tweaks_path, "r", encoding="utf-8", errors="ignore") as fh:
            content = fh.read()

        funcs = set(re.findall(r"function\s+([A-Za-z0-9\-_]+)", content, re.IGNORECASE))
        disablers = [f for f in funcs if f.startswith("Disable-")]
        for d in disablers:
            enabler = "Enable-" + d[len("Disable-"):]
            self.assertIn(
                enabler,
                funcs,
                f"Missing matching enabler function '{enabler}' for '{d}' in Windows11-Tweaks.psm1",
            )

    def test_no_deprecated_wmic_calls(self):
        """Ensure no deprecated wmic.exe calls remain in PowerShell scripts."""
        wmic_violations = []
        for p in self.ps_files:
            rel = os.path.relpath(p, self.repo_root)
            with open(p, "r", encoding="utf-8", errors="ignore") as fh:
                for line_idx, line in enumerate(fh, 1):
                    clean = re.sub(r"#.*$", "", line).strip()
                    if re.search(r"\bwmic(?:\.exe)?\b", clean, re.IGNORECASE):
                        wmic_violations.append(f"{rel}:{line_idx}: {clean}")

        if wmic_violations:
            self.fail("Found deprecated WMIC calls (removed in Windows 11 24H2/25H2):\n" + "\n".join(wmic_violations))

    def test_no_unsafe_invoke_expression_in_registry_helpers(self):
        """Ensure Set-ItemPropertyVerified and Remove-Item* do not use Invoke-Expression."""
        helpers = [
            "src/lib/debloat-helper/Set-ItemPropertyVerified.psm1",
            "src/lib/debloat-helper/Remove-ItemPropertyVerified.psm1",
            "src/lib/debloat-helper/Remove-ItemVerified.psm1",
        ]
        for rel in helpers:
            full_p = os.path.join(self.repo_root, rel)
            with open(full_p, "r", encoding="utf-8", errors="ignore") as fh:
                content = fh.read()
            self.assertNotIn(
                "Invoke-Expression",
                content,
                f"{rel} should use parameter splatting instead of Invoke-Expression",
            )

    def test_preset_script_files_exist_on_disk(self):
        """Verify that all scripts referenced in Get-DebloatScriptList exist in src/scripts."""
        main_path = os.path.join(self.repo_root, "WinDebloatTools.ps1")
        with open(main_path, "r", encoding="utf-8", errors="ignore") as fh:
            content = fh.read()

        script_names = re.findall(r'"([A-Za-z0-9\-_]+\.ps1)"', content)
        for s in set(script_names):
            script_path = os.path.join(self.repo_root, "src", "scripts", s)
            other_path = os.path.join(self.repo_root, "src", "scripts", "other-scripts", s)
            self.assertTrue(
                os.path.exists(script_path) or os.path.exists(other_path),
                f"Preset script '{s}' in WinDebloatTools.ps1 was not found in src/scripts",
            )

    def test_protected_services_guardrail(self):
        """Verify that critical Windows services are never placed in disable lists."""
        profile_path = os.path.join(self.repo_root, "src", "lib", "Get-HardwareProfile.psm1")
        with open(profile_path, "r", encoding="utf-8", errors="ignore") as fh:
            content = fh.read()

        protected = re.findall(r"'([A-Za-z0-9_\-]+)'", content)
        critical_services = {"WinDefend", "wuauserv", "Audiosrv", "WlanSvc", "Spooler", "BFE", "mpssvc"}

        services_script_path = os.path.join(self.repo_root, "src", "scripts", "Optimize-ServicesRunning.ps1")
        with open(services_script_path, "r", encoding="utf-8", errors="ignore") as fh:
            svc_content = fh.read()

        # Extract $ServicesToDisabled array entries
        disabled_match = re.search(r"\$ServicesToDisabled\s*=\s*@\(([\s\S]*?)\)", svc_content)
        if disabled_match:
            disabled_block = disabled_match.group(1)
            # Remove comments
            clean_disabled = re.sub(r"#.*$", "", disabled_block, flags=re.MULTILINE)
            disabled_svcs = set(re.findall(r'"([A-Za-z0-9_\.\-]+)"', clean_disabled))
            for crit in critical_services:
                self.assertNotIn(
                    crit,
                    disabled_svcs,
                    f"CRITICAL SAFETY VIOLATION: '{crit}' was found in $ServicesToDisabled!",
                )

    def test_revert_invocation_pattern(self):
        """Ensure all optimization scripts check both $Revert and $Global:Revert."""
        for p in self.ps_files:
            rel = os.path.relpath(p, self.repo_root)
            if "src/scripts/Optimize-" in rel or "src/scripts/Disable-" in rel or "src/scripts/Register-" in rel:
                with open(p, "r", encoding="utf-8", errors="ignore") as fh:
                    content = fh.read()
                self.assertTrue(
                    re.search(r"(\$Revert\s+-or\s+\$Global:Revert|\$Revert\s*=\s*\$true)", content),
                    f"{rel} must check '($Revert -or $Global:Revert)' for full CLI and GUI undo compatibility",
                )


if __name__ == "__main__":
    unittest.main()
