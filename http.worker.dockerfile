FROM python:3.8-slim
RUN pip install -U pip

RUN mkdir -p /neurogenpy/neurogenpy_http
COPY ./neurogenpy_http/requirements-worker.txt /neurogenpy/neurogenpy_http/requirements-worker.txt
RUN pip install -r /neurogenpy/neurogenpy_http/requirements-worker.txt

COPY ./requirements.txt /neurogenpy/requirements.txt
RUN pip install -r /neurogenpy/requirements.txt

COPY . /neurogenpy
WORKDIR /neurogenpy

RUN pip install .

USER nobody

ENTRYPOINT celery -A neurogenpy_http.scheduling.worker.app worker -l INFO