#!/bin/bash

docker run --rm --name aw-ocr1 --mount type=bind,source=/data/programming/,target=/app -it aw-ocr:latest

