/*
 * Custom SSDT: Enable D3cold for PCIe root port RP11 (0000:00:06.0, NVMe)
 *
 * HP EliteBook 840 G11 / Meteor Lake: BIOS SSDT10 gates the entire D3cold
 * block (_PR3, RAPR, _S0W) on the RD3S bit in ACPI NVS.  That bit is 0, so
 * D3cold is never enabled for RP11.  Without D3cold the bridge stays in D3hot
 * during suspend, preventing S0ix deep sleep.
 *
 * L23D (link up from L23) and DL23 (link down to L23) are defined in the
 * DSDT for this root port and are required for proper D3cold entry/exit —
 * without them the PCIe link does not recover after D3cold, making the NVMe
 * inaccessible on resume.
 *
 * _S0W is intentionally omitted.  With _S0W=4, bridge_d3=true causes the PCIe
 * port driver to immediately runtime-suspend RP11 to D3cold (DL23) before the
 * nvme driver probes, making the NVMe inaccessible at boot (ENODEV).  Without
 * _S0W, bridge_d3=false blocks runtime-PM D3cold while _PR3 still enables
 * D3cold via the ACPI system-suspend path for S0ix.
 */
DefinitionBlock ("rp11-d3cold.aml", "SSDT", 5, "JAKE  ", "RP11D3C ", 0x00000001)
{
    External (\_SB.PC00.RP11, DeviceObj)
    External (\_SB.PC00.RP11.DL23, MethodObj)
    External (\_SB.PC00.RP11.L23D, MethodObj)

    Scope (\_SB.PC00.RP11)
    {
        Method (_S0W, 0, NotSerialized)
        {
            Return (0x04)
        }
    }
}
