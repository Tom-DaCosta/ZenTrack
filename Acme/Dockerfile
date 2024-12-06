FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/ankraft/ACME-oneM2M-CSE.git

RUN cd ACME-oneM2M-CSE && \
    pip install -r requirements.txt

COPY acme.ini /ACME-oneM2M-CSE/acme.ini
COPY setup_in.sh /setup_in.sh

RUN chmod +x /ACME-oneM2M-CSE/acme.ini
RUN chmod +x /setup_in.sh

EXPOSE 8080

CMD ["/bin/bash", "-c", "/setup_in.sh"]