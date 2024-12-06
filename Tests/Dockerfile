FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    sudo

COPY test.sh /test.sh

RUN chmod +x /test.sh

CMD ["/bin/bash", "-c", "/test.sh"]