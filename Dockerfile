ARG PYTHON_VERSION=3.12-slim

FROM python:${PYTHON_VERSION}

ARG CROSSPLANE_VERSION=v1.17.3

RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sL "https://raw.githubusercontent.com/crossplane/crossplane/main/install.sh" | env XP_VERSION="$CROSSPLANE_VERSION" sh && \
    mv crossplane /usr/local/bin

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    USER=appuser

RUN adduser --disabled-password --gecos "" ${USER}

USER ${USER}
ENV PATH="/home/${USER}/.local/bin:${PATH}"

WORKDIR /app

COPY requirements.txt .

COPY environment.py .

COPY cucumber_json.py .

COPY steps/ ./steps

RUN pip install -r requirements.txt

ENTRYPOINT behave