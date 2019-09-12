#!/usr/bin/env python3
# coding=utf-8

import glob
import os
import zipfile


def get_midlet_name(fin):
    with zipfile.ZipFile(fin) as myzip:
        with myzip.open('META-INF/MANIFEST.MF') as myfile:
            manifest_raw = [line.strip().decode().split(':')
                            for line in myfile.readlines() if line.strip()]
            manifest = {item[0]: item[1]
                        for item in manifest_raw if len(item) == 2}
            return "{}:{}".format(manifest.get('MIDlet-Vendor',"Foo").replace("/","-"),manifest['MIDlet-Name'])


if __name__ == "__main__":
    jarlist = glob.glob("*.jar")
    for jar in jarlist:
        try:
            new_name = get_midlet_name(jar)+".jar"
            print("Renaming {} to {}".format(jar, new_name))
            os.rename(jar, new_name)
        except UnicodeDecodeError as err:
            print("Not processing {} due to incorrect coding : {}".format(
                jar, str(err)))
        except KeyError:
            print("Not processing {} due to lack of Midlet-Name in manifest".format(jar))
        except zipfile.BadZipFile:
            print("Not processing {} due to not a jar file".format(jar))

