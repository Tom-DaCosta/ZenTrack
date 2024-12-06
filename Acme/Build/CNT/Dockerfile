FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    sudo

COPY Build/CNT/CNT_Builder.sh /CNT_Builder.sh

RUN chmod +x /CNT_Builder.sh

CMD ["/bin/bash", "-c", " /CNT_Builder.sh"]