# Stage 1: Builder
FROM python:3.13-slim AS builder

WORKDIR /srv/oxylus

RUN apt-get update \
    && apt-get install -y curl build-essential openssh-client git \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y libmagic-dev \
    && pip install --upgrade pip poetry dynaconf \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./pyproject.toml ./
COPY ./ox_server ./ox_server
COPY ./README.rst ./README.rst
RUN poetry config virtualenvs.in-project true
RUN poetry install --with prod --verbose

ENV CI=true

# Stage 2: Runtime image (lean)
FROM python:3.13-slim AS runtime

WORKDIR /srv/oxylus
ENV PATH="/srv/oxylus/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

RUN apt-get update \
    && apt-get install -y python3-poetry libpq5 libmagic-dev \
    && pip install --upgrade pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy built artifacts from builder
COPY --from=builder /srv/oxylus/ox_server ./ox_server
COPY --from=builder /srv/oxylus/pyproject.toml ./pyproject.toml
COPY --from=builder /srv/oxylus/poetry.lock ./poetry.lock
COPY --from=builder /srv/oxylus/README.rst ./README.rst
COPY --from=builder /srv/oxylus/.venv ./.venv

RUN poetry config virtualenvs.in-project true
RUN poetry lock
RUN poetry update --with prod


COPY ./run.sh ./
RUN chmod +x ./run.sh


ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

EXPOSE 8000
ENTRYPOINT ["/srv/oxylus/run.sh"]
CMD run
