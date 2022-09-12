FROM 763104351884.dkr.ecr.us-west-2.amazonaws.com/pytorch-training:1.11-gpu-py38
#FROM nvcr.io/nvidia/pytorch:21.08-py3
#RUN apt update
#RUN apt install -y zip htop libgl1-mesa-glx


# /opt/ml and all subdirectories are utilized by SageMaker, we use the /code 
#subdirectory to store our user code.
ENV SM_CODE_DIR=/opt/ml/code/
ENV PATH="{SM_CODE_DIR}:${PATH}"


COPY cfg $SM_CODE_DIR/cfg
COPY data $SM_CODE_DIR/data
COPY dataset_cfg $SM_CODE_DIR/dataset_cfg
COPY src $SM_CODE_DIR/src
COPY scripts $SM_CODE_DIR/scripts
COPY weights $SM_CODE_DIR/weights
COPY model_data $SM_CODE_DIR/model_data
COPY Pipfile $SM_CODE_DIR/
COPY Pipfile.lock $SM_CODE_DIR/
COPY train.sh $SM_CODE_DIR/
COPY test.sh $SM_CODE_DIR/

#COPY requirements.txt /requirements.txt

#RUN pip install -r /requirements.txt
#RUN pip install seaborn thop
# Remove existing torch installation since it's the wrong version

WORKDIR $SM_CODE_DIR

#ENV WORKON_HOME=~/.venvs
#ENV PIPENV_VENV_IN_PROJECT=1
ENV VIRTUAL_ENV=/venv
RUN python3 -m venv $VIRTUAL_ENV --system-site-packages
# add the virtualenv python to the front of the path so it is the default python
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV PIPENV_VERBOSITY=-1
RUN pip install pipenv
RUN pipenv install --site-packages --skip-lock
#RUN pipenv sync
#RUN 
#RUN pipenv install --deploy --ignore-pipfile
#RUN pipenv shell


# this environment variable is used by the SageMaker PyTorch container to determine our user code directory.
ENV SAGEMAKER_SUBMIT_DIRECTORY $SM_CODE_DIR

# this environment variable is used by the SageMaker PyTorch container to determine our program entry point
# for training and serving.
# For more information: https://github.com/aws/sagemaker-pytorch-container
ENV SAGEMAKER_PROGRAM train.py
