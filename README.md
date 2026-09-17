# Lucreticus Control

Small KernelSU WebUI module for kernels that expose the Lucreticus CPUFreq governors and optional Mali or MediaTek boost parameters.

Install the module ZIP through KernelSU, open its WebUI, and choose `lucretiperf`, `lucretibalance`, `lucretibattery`, or `schedutil`. The module is passive at boot and does not force a governor or enable experimental features automatically.

The measurement screen runs the bundled root helper. Repeat the same workload for each governor, then copy the output directories from `/sdcard/Download/` and summarize them with `tools/lucreticus/summarize_governors.py` from the kernel source tree.

The WebUI requires KernelSU’s WebUI `exec` API and the module path `/data/adb/modules/lucreticus-control`. It does not require a kernel build.
