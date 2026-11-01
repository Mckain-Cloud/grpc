#!/bin/bash
# Copyright 2026 gRPC authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Strip debug symbols from a wheel's extension modules in place, before
# auditwheel repair (which rewrites RECORD, so hashes need not be fixed here).
# Without this the cp314t/cp315t grpcio wheels are ~200 MB instead of ~8 MB.
#
# Usage (cibuildwheel):
#   CIBW_REPAIR_WHEEL_COMMAND_LINUX: >-
#     bash /project/tools/distrib/python/strip_wheel.sh {wheel} &&
#     auditwheel repair -w {dest_dir} {wheel}
set -euo pipefail

wheel=$(realpath "$1")
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cd "$tmp"
python -m zipfile -e "$wheel" .
echo "Before strip:"
find . -name '*.so' -exec ls -l {} \;
find . -name '*.so' -exec strip --strip-debug {} \;
echo "After strip:"
find . -name '*.so' -exec ls -l {} \;
rm -f "$wheel"
python -m zipfile -c "$wheel" ./*
ls -l "$wheel"
