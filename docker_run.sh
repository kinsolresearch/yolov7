#!/bin/bash
docker run --gpus all --shm-size=64g --rm -it -v $PWD:/opt/ml/code -v /mnt/NAS/Public/datasets/speedco_dataset:/opt/ml/code/speedco_dataset yolov7-gpu bash
