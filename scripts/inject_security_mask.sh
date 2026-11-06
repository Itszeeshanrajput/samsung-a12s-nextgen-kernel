#!/usr/bin/env bash
# ==============================================================================
# Play Integrity & Bootloader Flag Stealth Masker
# Mask androidboot.verifiedbootstate=green and androidboot.flash.locked=1
# ==============================================================================

set -euo pipefail

KERNEL_DIR="${1:-.}"
cd "$KERNEL_DIR"

echo "[*] Injecting Play Integrity cmdline masking..."

CMDLINE_C="fs/proc/cmdline.c"
if [ -f "$CMDLINE_C" ]; then
    cat << 'EOF' > "$CMDLINE_C"
// SPDX-License-Identifier: GPL-2.0
#include <linux/fs.h>
#include <linux/init.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/string.h>
#include <linux/slab.h>

static int cmdline_proc_show(struct seq_file *m, void *v)
{
	char *buf;
	char *p;

	if (!saved_command_line)
		return 0;

	buf = kstrdup(saved_command_line, GFP_KERNEL);
	if (!buf) {
		seq_puts(m, saved_command_line);
		seq_putc(m, '\n');
		return 0;
	}

	/* Mask bootloader unlock flags for Play Integrity / Knox bypass */
	p = strstr(buf, "androidboot.verifiedbootstate=orange");
	if (p)
		memcpy(p + 30, "green ", 6);

	p = strstr(buf, "androidboot.verifiedbootstate=yellow");
	if (p)
		memcpy(p + 30, "green ", 6);

	p = strstr(buf, "androidboot.flash.locked=0");
	if (p)
		*(p + 25) = '1';

	seq_puts(m, buf);
	seq_putc(m, '\n');
	kfree(buf);
	return 0;
}

static int __init proc_cmdline_init(void)
{
	proc_create_single("cmdline", 0, NULL, cmdline_proc_show);
	return 0;
}
fs_initcall(proc_cmdline_init);
EOF
    echo "[✓] Cmdline verifiedbootstate and flash.locked spoofing injected."
fi
