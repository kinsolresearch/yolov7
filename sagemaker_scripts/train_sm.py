# Use Amazon SageMaker to train a model on a GPU
import sagemaker as sm
from sagemaker.pytorch import PyTorch
from sagemaker.local import LocalSession
from sagemaker.s3 import S3Downloader
import logging

session = sm.Session()
#session = LocalSession()
#session.config = {'local': {'local_code': True}}

bucket = session.default_bucket()
region = session.boto_region_name
print(f"Region: {region}")
role = 'arn:aws:iam::715375150409:role/service-role/AmazonSageMaker-ExecutionRole-20210706T080639'
print(f"Default bucket: {bucket}")

hyperparameters = {
    'workers':8,
    # 'device': 0,
    'batch-size':15,
    'epochs':1,
    'data':'dataset_cfg/speedco_small.yaml',
    'img':'640 640',
    'cfg':'cfg/training/yolov7.yaml',
    'weights':'weights/yolov7_training.pt',
    'name':'yolov7-speedco',
    'hyp':'data/hyp.scratch.p5.yaml',
    'project': '/opt/ml/model'
}

estimator = PyTorch(
    role=role,
    instance_count=1,
    instance_type='ml.p2.xlarge',
    #instance_type='ml.m5.large',
    #instance_type='ml.t3.medium',
    #instance_type='local_gpu',
    max_run=3 * 24 * 60 * 60,
    input_mode='FastFile',
    #use_spot_instances=True,
    #tensorboard_output_config={'Outputs': 's3://{}/tensorboard'.format(sm.s3_default_bucket())},
    entry_point='train.py',
    dependencies=['dataset_cfg', 'cfg', 'data', 'weights'],
    source_dir='src',
    #image_uri='715375150409.dkr.ecr.us-west-2.amazonaws.com/yolov7-gpu:latest',
    #image_uri='yolov7-gpu:latest',
    hyperparameters=hyperparameters,
    framework_version='1.11',
    py_version='py38',
    # checkpoint_local_path='/opt/ml/checkpoints/',
    # checkpoint_s3_uri='s3://{}/checkpoints/'.format(bucket),
    enable_sagemaker_metrics=True,
    container_log_level=logging.INFO
)

from sagemaker.inputs import TrainingInput
print(f"Finished creating estimator")
train_input = TrainingInput(
    's3://speedco-dataset-small/train/',
    s3_data_type='S3Prefix',
    # content_type='application/x-image',

)
estimator.fit(
    # {'train': f's3://{bucket}/samples/datasets/imdb/train'}
    #{'train': 's3://speedco-dataset-small/JPEGImages'}
    {'train': train_input}
    #{'train': 'file:///tmp/speedco_dataset/JPEGImages'}
    # 'test': 's3://speedco-dataset'}
)
