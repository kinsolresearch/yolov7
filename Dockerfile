FROM nvcr.io/nvidia/pytorch:22.05-py3

ENV CODE_DIR=/yolo
ENV PATH="{CODE_DIR}:${PATH}"

COPY cfg $CODE_DIR/cfg
COPY data $CODE_DIR/data
COPY dataset_cfg $CODE_DIR/dataset_cfg
COPY src $CODE_DIR/src
COPY scripts $CODE_DIR/scripts
COPY weights $CODE_DIR/weights
COPY Pipfile $CODE_DIR/
COPY Pipfile.lock $CODE_DIR/

WORKDIR $CODE_DIR

ENV VIRTUAL_ENV=/venv
RUN python3 -m venv $VIRTUAL_ENV --system-site-packages
# add the virtualenv python to the front of the path so it is the default python
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV PIPENV_VERBOSITY=-1
RUN pip install pipenv
RUN pipenv install --site-packages --skip-lock
