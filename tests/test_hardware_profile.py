"""Pure-logic tests for Resolve-HardwareProfile thresholds.

Mirrors src/lib/Get-HardwareProfile.psm1 so CI can run on Linux
without Windows PowerShell or CIM.
"""

from __future__ import annotations

import unittest


def resolve_hardware_profile(
    ram_gb: float,
    cpu_cores: int,
    drive_type: str,
    free_disk_gb: float = 64.0,
    is_laptop: int = 0,
    override_name: str = "",
) -> dict:
    drive = "SSD"
    lowered = (drive_type or "").lower()
    if lowered in {"", "hdd", "unspecified", "unspecifiedhdd"} or "hdd" in lowered:
        drive = "HDD"
    elif any(token in lowered for token in ("ssd", "nvme", "scm")):
        drive = "SSD"
    else:
        drive = drive_type

    name = "HighEnd"
    if ram_gb <= 4.5 or (ram_gb <= 6.5 and drive == "HDD"):
        name = "ExtremeLowEnd"
    elif ram_gb <= 8.5 or drive == "HDD" or cpu_cores <= 2:
        name = "LowEnd"
    elif ram_gb <= 16.5:
        name = "MidRange"

    if override_name in {"ExtremeLowEnd", "LowEnd", "MidRange", "HighEnd"}:
        name = override_name

    constrained = name in {"ExtremeLowEnd", "LowEnd"}
    return {
        "Name": name,
        "RamGB": round(ram_gb, 1),
        "CpuCores": cpu_cores,
        "DriveType": drive,
        "FreeDiskGB": round(free_disk_gb, 1),
        "IsLaptop": bool(is_laptop),
        "IsConstrained": constrained,
        "DisableSysMain": constrained or drive == "HDD",
        "DisableSearch": name == "ExtremeLowEnd" or drive == "HDD" or ram_gb <= 8.5,
        "AggressiveVisuals": constrained,
        "DisableTransparency": name != "HighEnd",
        "DisableAnimations": constrained,
        "UseCompactOS": (free_disk_gb < 20) or (name == "ExtremeLowEnd" and free_disk_gb < 40),
        "DisableHibernate": (not bool(is_laptop)) and (name == "ExtremeLowEnd" or free_disk_gb < 15),
        "SystemResponsiveness": 10,
        "EnableHAGS": name in {"MidRange", "HighEnd"},
        "PagefileStrategy": "FixedLowRam" if name == "ExtremeLowEnd" else "SystemManaged",
        "KeepMemoryCompression": True,
        "ProtectDefender": True,
        "ProtectWindowsUpdate": True,
    }


class HardwareProfileTests(unittest.TestCase):
    def test_extreme_4gb_hdd(self):
        p = resolve_hardware_profile(4, 2, "HDD", 20, 0)
        self.assertEqual(p["Name"], "ExtremeLowEnd")
        self.assertTrue(p["IsConstrained"])
        self.assertTrue(p["DisableSysMain"])
        self.assertTrue(p["DisableSearch"])
        self.assertTrue(p["AggressiveVisuals"])
        self.assertTrue(p["DisableHibernate"])
        self.assertFalse(p["EnableHAGS"])
        self.assertEqual(p["PagefileStrategy"], "FixedLowRam")
        self.assertEqual(p["SystemResponsiveness"], 10)
        self.assertTrue(p["KeepMemoryCompression"])

    def test_extreme_4gb_ssd(self):
        p = resolve_hardware_profile(4, 4, "SSD", 40, 0)
        self.assertEqual(p["Name"], "ExtremeLowEnd")
        self.assertTrue(p["DisableSysMain"])
        self.assertFalse(p["EnableHAGS"])

    def test_6gb_hdd_is_extreme(self):
        p = resolve_hardware_profile(6, 4, "HDD", 50, 0)
        self.assertEqual(p["Name"], "ExtremeLowEnd")

    def test_8gb_ssd_is_low_end(self):
        p = resolve_hardware_profile(8, 4, "SSD", 80, 0)
        self.assertEqual(p["Name"], "LowEnd")
        self.assertTrue(p["DisableSearch"])
        self.assertTrue(p["DisableSysMain"])
        self.assertTrue(p["DisableTransparency"])
        self.assertFalse(p["EnableHAGS"])

    def test_16gb_ssd_is_mid(self):
        p = resolve_hardware_profile(16, 6, "SSD", 200, 0)
        self.assertEqual(p["Name"], "MidRange")
        self.assertFalse(p["IsConstrained"])
        self.assertFalse(p["DisableSysMain"])
        self.assertFalse(p["DisableSearch"])
        self.assertTrue(p["EnableHAGS"])
        self.assertTrue(p["DisableTransparency"])
        self.assertFalse(p["DisableAnimations"])

    def test_32gb_nvme_is_high(self):
        p = resolve_hardware_profile(32, 8, "NVMe", 400, 0)
        self.assertEqual(p["Name"], "HighEnd")
        self.assertEqual(p["DriveType"], "SSD")
        self.assertFalse(p["DisableTransparency"])
        self.assertTrue(p["EnableHAGS"])
        self.assertEqual(p["PagefileStrategy"], "SystemManaged")

    def test_hdd_always_disables_sysmain_and_search(self):
        p = resolve_hardware_profile(32, 8, "HDD", 400, 0)
        self.assertEqual(p["Name"], "LowEnd")
        self.assertTrue(p["DisableSysMain"])
        self.assertTrue(p["DisableSearch"])

    def test_dual_core_is_low_end(self):
        p = resolve_hardware_profile(16, 2, "SSD", 100, 0)
        self.assertEqual(p["Name"], "LowEnd")

    def test_laptop_keeps_hibernate_even_when_extreme(self):
        p = resolve_hardware_profile(4, 2, "SSD", 10, 1)
        self.assertTrue(p["IsLaptop"])
        self.assertFalse(p["DisableHibernate"])

    def test_desktop_tiny_disk_disables_hibernate(self):
        p = resolve_hardware_profile(16, 4, "SSD", 10, 0)
        self.assertTrue(p["DisableHibernate"])

    def test_compactos_on_tiny_disk(self):
        p = resolve_hardware_profile(16, 4, "SSD", 12, 0)
        self.assertTrue(p["UseCompactOS"])

    def test_override_forces_extreme(self):
        p = resolve_hardware_profile(64, 16, "SSD", 1000, 0, override_name="ExtremeLowEnd")
        self.assertEqual(p["Name"], "ExtremeLowEnd")
        self.assertTrue(p["IsConstrained"])

    def test_never_sacrifice_security_defaults(self):
        for ram, cores, drive in ((4, 2, "HDD"), (8, 4, "SSD"), (32, 8, "SSD")):
            p = resolve_hardware_profile(ram, cores, drive)
            self.assertTrue(p["ProtectDefender"])
            self.assertTrue(p["ProtectWindowsUpdate"])
            self.assertTrue(p["KeepMemoryCompression"])


if __name__ == "__main__":
    unittest.main()
