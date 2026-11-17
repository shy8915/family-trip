#!/bin/sh
# 사용법: sh release.sh  → index.html과 version.json의 버전을 같은 값으로 맞춤
V=$(date +%Y%m%d%H%M%S)
python3 - "$V" <<'P'
import re,sys,json
v=sys.argv[1]
s=open('index.html',encoding='utf-8').read()
s=re.sub(r'const APP_VERSION="[^"]*";','const APP_VERSION="'+v+'";',s,1)
open('index.html','w',encoding='utf-8').write(s)
json.dump({"version":v},open('version.json','w'))
P
echo "version $V"
