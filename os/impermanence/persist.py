import grp
import os
import pwd
import stat
import subprocess
import sys
from pathlib import Path


def select_paths(src: Path) -> list[Path]:
    """
    Recursively lists all files and folders under `root` and opens fzf
    for interactive multi-selection. Returns the selected paths.
    """
    src = src.resolve()
    find_cmd = ["sh", "-c", "find . -xdev -mindepth 1 | sed 's|^./||'"]

    fzf_cmd = [
        "fzf",
        "--multi",
        "--layout=reverse-list",
        "--preview=cd " + str(src) + "; grc --colour=on stat {}",
    ]

    find_proc = subprocess.Popen(find_cmd, stdout=subprocess.PIPE, cwd=src, text=True)
    fzf_proc = subprocess.run(
        fzf_cmd,
        stdin=find_proc.stdout,
        capture_output=True,
        text=True,
    )
    find_proc.wait()

    if fzf_proc.returncode not in (0, 1):  # 1 = no match / user aborted
        raise RuntimeError(f"fzf exited with code {fzf_proc.returncode}")

    return [src / Path(line) for line in fzf_proc.stdout.splitlines() if line]


def make_nix(src: Path, paths: list[Path]) -> str:
    categorised = {}
    for p in paths:
        if p.relative_to(src).parts[0] == "home" and len(p.relative_to(src).parts) > 2:
            if p.is_dir():
                categorised.setdefault("users", {}).setdefault(
                    p.relative_to(src).parts[1], {}
                ).setdefault("directories", []).append(p)
            else:
                categorised.setdefault("users", {}).setdefault(
                    p.relative_to(src).parts[1], {}
                ).setdefault("files", []).append(p)
        else:
            if p.is_dir():
                categorised.setdefault("system", {}).setdefault(
                    "directories", []
                ).append(p)
            else:
                categorised.setdefault("system", {}).setdefault("files", []).append(p)

    nix = ""
    if "system" in categorised:
        if "directories" in categorised["system"]:
            nix += "directories = [\n"
            for p in categorised["system"]["directories"]:
                nix += "  " + make_nix_path(src, p) + "\n"
            nix += "];\n"
        if "files" in categorised["system"]:
            nix += "files = [\n"
            for p in categorised["system"]["files"]:
                nix += "  " + make_nix_path(src, p) + "\n"
            nix += "];\n"
    if "users" in categorised:
        for user in categorised["users"]:
            nix += 'users."' + user + '" = {\n'
            if "directories" in categorised["users"][user]:
                nix += "  directories = [\n"
                for p in categorised["users"][user]["directories"]:
                    nix += "    " + make_nix_path(src, p, user=user) + "\n"
                nix += "  ];\n"
            if "files" in categorised["users"][user]:
                nix += "  files = [\n"
                for p in categorised["users"][user]["files"]:
                    nix += "    " + make_nix_path(src, p, user=user) + "\n"
                nix += "  ];\n"
            nix += "};\n"

    return nix


def make_nix_path(src: Path, path: Path, user=None):
    group = None
    mode = "0755"
    if user is None:
        user = "root"
        group = "root"
    else:
        group = "users"
    is_dir = path.is_dir()
    st = os.stat(path if is_dir else path.parent)

    actual = {
        "user": (pwd.getpwuid(st.st_uid).pw_name, user),
        "group": (grp.getgrgid(st.st_gid).gr_name, group),
        "mode": (f"{stat.S_IMODE(st.st_mode):04o}", mode),
    }

    mismatches = {
        k: v
        for k, (v, expected) in actual.items()
        if expected is not None and v != expected
    }

    nix_path = ""
    if user != "root":
        nix_path = str(Path(*path.relative_to(src).parts[2:]))
    else:
        nix_path = "/" + str(path.relative_to(src))

    if not mismatches:
        return '"' + nix_path + '"'

    attrs = "; ".join(f'{k} = "{v}"' for k, v in mismatches.items())

    if is_dir:
        return "{ " + f'directory = "{nix_path}"; {attrs};' + " }"
    else:
        return "{ " + f'file = "{nix_path}"; parentDirectory = {{ {attrs}; }};' + " }"


def filter_paths(paths: list[Path]) -> list[Path]:
    """
    Remove any path that is a subpath (descendant) of another path in the list.
    i.e. if both 'foo/' and 'foo/bar' are selected, keep only 'foo/'.
    """
    sorted_paths = sorted(paths)  # shorter paths come first
    kept: list[Path] = []

    for candidate in sorted_paths:
        # Check whether any already-kept path is a parent of this candidate
        if not any(
            candidate != keeper and candidate.parts[: len(keeper.parts)] == keeper.parts
            for keeper in kept
        ):
            kept.append(candidate)
    return kept


def copy_exact(a: str, b: str) -> None:
    script = """
if [ -d "$a" ]; then
  mkdir -p "$b"
  chmod --reference="$a" "$b"
  chown --reference="$a" "$b"
  rsync -aHAX --delete "${a%/}/" "${b%/}/"
else
  mkdir -p "$(dirname "$b")"
  chmod --reference="$(dirname "$a")" "$(dirname "$b")"
  chown --reference="$(dirname "$a")" "$(dirname "$b")"
  rsync -aHAX "$a" "$b"
fi
"""
    subprocess.run(
        ["sh", "-c", script],
        env={"a": a, "b": b, "PATH": os.environ["PATH"]},
        check=True,
    )


def copy_paths(source_root, dest_root, paths):
    rel_paths = [p.relative_to(source_root) for p in paths]
    for rel_path in rel_paths:
        src = os.path.join(source_root, rel_path)
        dst = os.path.join(dest_root, rel_path)
        copy_exact(src, dst)


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit(f"Usage: {sys.argv[0]} <src> <dst>")

    src = Path(sys.argv[1]).expanduser().resolve()
    dst = Path(sys.argv[2]).expanduser().resolve()

    for path in (src, dst):
        if not path.is_dir():
            sys.exit(f"Error: path '{path}' is not a directory.")

    selected = select_paths(src)

    print(f"Selected {len(selected)} paths")

    filtered = filter_paths(selected)

    if len(filtered) != len(selected):
        print(f"Skipping {len(selected) - len(filtered)} duplicates")

    print()
    copy_paths(src, dst, filtered)
    print("Copied:")
    [print(str(p)) for p in filtered]

    print()
    print("Nix:")
    print(make_nix(src, filtered))


if __name__ == "__main__":
    main()
