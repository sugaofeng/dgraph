#!/bin/bash

SRC="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

BUILD=$1
# If build variable is empty then we set it.
if [ -z "$1" ]; then
	  BUILD=$SRC/build
fi

ROCKSDBDIR=$BUILD/rocksdb-4.2

set -e

# build flags needed for rocksdb
export CGO_CFLAGS="-I${ROCKSDBDIR}/include"
export CGO_LDFLAGS="-L${ROCKSDBDIR}"
export LD_LIBRARY_PATH="${ROCKSDBDIR}:${LD_LIBRARY_PATH}"

pushd cmd/dgraph &> /dev/null
go build .
mkdir -p ~/dgraph/m
# Start dgraph in the background.
./dgraph --mutations ~/dgraph/m --postings ~/dgraph/p --uids ~/dgraph/u &

pushd $BUILD/benchmarks/throughputtest &> /dev/null
go build . && ./throughputtest --numsec 60 --ip "http://127.0.0.1:8080/query"  --numuser 1000
popd &> /dev/null

popd &>/dev/null