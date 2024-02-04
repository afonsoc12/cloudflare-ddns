# Cloudflare DDNS updater

[![Docker Pulls](https://img.shields.io/docker/pulls/afonsoc12/cloudflare-ddns?logo=docker)](https://hub.docker.com/repository/docker/afonsoc12/cloudflare-ddns)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[![Github Starts](https://img.shields.io/github/stars/afonsoc12/cloudflare-ddns?logo=github)](https://github.com/afonsoc12/cloudflare-ddns)
[![Github Fork](https://img.shields.io/github/forks/afonsoc12/cloudflare-ddns?logo=github)](https://github.com/afonsoc12/cloudflare-ddns)
[![Github Release](https://img.shields.io/github/v/release/afonsoc12/cloudflare-ddns?logo=github)](https://github.com/afonsoc12/cloudflare-ddns/releases)

A lightweight script to dynamically update DNS records using [cloudflare](https://cloudflare.com) API. It is packaged as docker container based on [alpine](https://hub.docker.com/_/alpine) image, built for `linux/amd64`, `linux/arm64` and `linux/arm/v7` architectures.

> Note: Archiving this repo in favour of [hotio's cloudflareddns](https://github.com/hotio/cloudflareddns). Please check that project for more information.

# Instalation

The image can be pulled from both [DockerHub](https://hub.docker.com/r/afonsoc12/cloudflare-ddns) and [ghcr.io](https://github.com/afonsoc12/cloudflare-ddns/pkgs/container/cloudflare-ddns) container registries.

For simplicity and to be [k8s](https://kubernetes.io/) [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) friendly, it does not include any scheduling. The container will start, run the script and exit.

```shell
# You can also specify a version as the tag, such as afonsoc12/cloudflare-ddns:2022.10.17
docker pull afonsoc12/cloudflare-ddns:latest

# Run container once
docker run --rm \
    --name cloudflare-ddns \
    -e CLOUDFLARE_API_TOKEN=<API TOKEN> \
    -e CLOUDFLARE_ZONE_ID=<ZONE ID> \
    -e CLOUDFLARE_RECORD_NAME=ip.mydomain.xyz \
    -e TTL=1 `# optional` \
    -e PROXY=false `# optional` \
    afonsoc12/cloudflare-ddns
```

## Cloudflare API credentials

You'll need to create a new API Token [from this page](https://dash.cloudflare.com/profile/api-tokens). Please select the options below:

- Permissions:

    - `Zone - Zone - Read`
    - `Zone - DNS - Edit`

- Zone Resources:

    - `Include - Specific zone - mydomain.xyz`

        OR
    - `Include - All zones`

Additionally, the cloudflare Zone ID is also needed. It can be gathered from the "Overview" tab. You'll find it on the right panel of the page.

## Environment Variables

| Variable | Function |
| :----: | --- |
| `CLOUDFLARE_API_TOKEN` | Cloudflare API Token. Must have permission `Zone - Zone - Read` and `Zone - DNS - Edit`. Zone Resources can be `Include - Specific zone - mydomain.xyz`. |
| `CLOUDFLARE_ZONE_ID` | Cloudflare Zone ID. Can be found in the "Overview" tab of your domain. |
| `CLOUDFLARE_RECORD_NAME` | Cloudflare record to be updated with new IP. |
| `TTL` | Set the DNS TTL (seconds). |
| `PROXY` | Enable cloudflare proxy (true or false). |


## Credits

Copyright 2022 Afonso Costa

Licensed under the [Apache License, Version 2.0](https://github.com/afonsoc12/cloudflare-ddns/blob/master/LICENSE) (the "License")
