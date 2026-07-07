FROM gzurowski/latex-devcontainer:latest-full@sha256:4d93c8cf662153a6ce773e4db7f6757ff8f463b0a22a6c8187c3387c7b909641
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 python3-pip ghostscript \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt

RUN python3 -m pip install --no-cache-dir --break-system-packages -r /tmp/requirements.txt \
    && rm -f /tmp/requirements.txt
