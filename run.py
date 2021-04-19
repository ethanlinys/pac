import os
import json
from datetime import datetime

import requests

SOURCE_ADDR = "https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf"

local_finename = "accelerated-domains.china.conf"
tpl_finename = "pac.tpl"
output_finename = "pac.js"

# download the conf file
with requests.get(SOURCE_ADDR, stream=True) as r:
    r.raise_for_status()
    with open(local_finename, "wb") as f:
        for chunk in r.iter_content(chunk_size=8192):
            f.write(chunk)

# convert conf file to list
with open(local_finename) as f:
    with open(tpl_finename) as tpl_f:
        tpl_text = tpl_f.read()
        with open(output_finename, "w") as out_f:
            out_f.write(f"// {datetime.now()}\n")
            domain_dict = {}
            for line in f.read().splitlines():
                if line.strip():
                    if line.startswith("#"):
                        continue
                    domain_str = line.split("/")[1]
                    if "." not in domain_str:
                        continue
                    suffix = domain_str.split(".")[-1]
                    host = ".".join(domain_str.split(".")[:-1])
                    if not domain_dict.get(suffix, None):
                        domain_dict[suffix] = {}
                    domain_dict[suffix][host] = 1
            tpl_text = tpl_text.replace("DOMAIN_DICT_PLACEHOLDER", json.dumps(domain_dict))
            out_f.write(tpl_text)

# remove conf file
os.remove(local_finename)
