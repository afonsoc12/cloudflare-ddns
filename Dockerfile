FROM alpine:latest

ARG USER=coolio \
    GROUP=coolio \
    UID=1234 \
    GID=4321

WORKDIR /home

COPY cloudflare-ddns.sh /home

RUN mkdir -p /home \
    && apk add --no-cache tzdata curl jq \
    && addgroup --gid $GID $GROUP \
    && adduser -D -H --gecos "" \
                     --home "/home" \
                     --ingroup "$GROUP" \
                     --uid "$UID" \
                     "$USER" \
    && chown -R $USER:$GROUP /home \
    && chmod u+x cloudflare-ddns.sh \
    && rm -rf /tmp/* /var/{cache,log}/* /var/lib/apt/lists/*

USER $USER

ENTRYPOINT ["./cloudflare-ddns.sh"]
