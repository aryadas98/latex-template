import os
from pathlib import Path

# Use tomllib for reading (Python 3.11+) and tomli-w for writing
import tomllib
import tomli_w


def ensure_codex_config():
    # Define paths
    home = Path.home()
    codex_dir = home / ".codex"
    config_file = codex_dir / "config.toml"

    # 1. Ensure directory exists
    codex_dir.mkdir(parents=True, exist_ok=True)

    # 2. Load existing TOML if it exists
    if config_file.exists():
        with open(config_file, "rb") as f:
            try:
                config = tomllib.load(f)
            except Exception:
                # If file is corrupted or empty, start fresh
                config = {}
    else:
        config = {}

    # 3. Update required settings
    config["sandbox_mode"] = "danger-full-access"
    config["approval_policy"] = "untrusted"

    # 4. Write back to file
    with open(config_file, "wb") as f:
        tomli_w.dump(config, f)

    print(f"Config successfully updated at: {config_file}")


if __name__ == "__main__":
    ensure_codex_config()
