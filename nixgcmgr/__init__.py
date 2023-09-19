import datetime
import os
from typing import Tuple, Optional

def try_stat_link(link: str) -> Tuple[str, Tuple[str, Optional[os.stat_result]]]:
    path = os.path.join('/nix/var/nix/gcroots/auto', link)
    target = os.readlink(path)
    lstat = None
    try:
        lstat = os.lstat(target)
    except (PermissionError, FileNotFoundError):
        pass
    return (path, (target, lstat))


def filter_not_ours(data: Tuple[str, Tuple[str, Optional[os.stat_result]]]) -> bool:
    if data[1][1] is None:
        return False
    uid = os.getuid()
    if uid != 0 and data[1][1].st_uid != uid:
        return False
    return True


def main() -> None:
    links = dict(
        filter(
            filter_not_ours,
            map(
                try_stat_link,
                os.listdir('/nix/var/nix/gcroots/auto/')
            )
        )
    );

    now = datetime.datetime.now()

    for gcroot, (target, lstat) in links.items():
        print(f" - {gcroot} -> {target}")
        if lstat is not None:
            print(f"   - owned by:   {lstat.st_uid}")
            ctime = datetime.datetime.fromtimestamp(lstat.st_ctime)
            print(f"   - created at: {ctime}")
            if ctime < (now - datetime.timedelta(days=30)):
                print("   - eligible for deletion")
        else:
            print("   (data unknown, no permission or broken link)")

