# ARM IP Directory

Placeholder for ARM commercial IP. Actual RTL is **not included** due to licensing.

On servers with a site-wide install, use symlinks:
```
common/arm_ip/
├── README.md          ← this file (tracked)
├── cm0_ds → /opt/arm_ip/CortexM0-DS   (symlink, .gitignore)
├── cm0/   → ...       (future)
├── cm4/   → ...       (future)
└── ethos/ → ...       (future)
```

## cm0_ds — Cortex-M0 DesignStart

| File | Description |
|------|-------------|
| `CORTEXM0INTEGRATION.v` | Top-level integration wrapper |
| `cortexm0ds_logic.v` | Core obfuscated logic |

### How to Obtain

1. Visit [ARM DesignStart](https://www.arm.com/resources/designstart)
2. Register and download **Cortex-M0 DesignStart** (free for evaluation)
3. Place the two files in `common/arm_ip/cm0_ds/`

### Makefile Reference

```makefile
ARM_IP ?= $(abspath ../../common/arm_ip)
# Files expected at $(ARM_IP)/cm0_ds/CORTEXM0INTEGRATION.v
```

## License

ARM IP is provided under the
[ARM DesignStart EULA](https://www.arm.com/resources/designstart/designstart-eula).
Redistribution of the RTL source is **not permitted**.
