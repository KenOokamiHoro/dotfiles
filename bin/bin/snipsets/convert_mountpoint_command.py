#!/usr/bin/env python3
if __name__ == "__main__":
    with open("mountpoints.txt") as fin:
        mountpoints = [line.strip().split(" ") for line in fin.readlines()]
        print('    "shamu")\n        sed -i \ ')
        for mount in mountpoints:
            if len(mount)==10:
                print("            -e 's block/platform/msm_sdcc.1/by-name/{} {} ' \ ".format(
                    mount[-3], mount[-1].replace("/dev/block/", "")))
        print('            "$@"\n        ;;')


