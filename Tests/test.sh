#!/bin/bash

echo "Ok1"

curl http://influxdb_container:8086

curl http://influxdb:8086

curl http://localhost:8086

echo "Ok2"