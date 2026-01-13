---
title: "Docker 代理配置"
date: "2024-06-04"
---


## Docker pull

{{< bar title="/etc/docker/daemon.json" >}}

```json
{
    "proxies": {
        "http-proxy": "http://127.0.0.1:7897",
        "https-proxy": "http://127.0.0.1:7897",
        "no-proxy": "localhost,127.0.0.1"
    }
}
```

- `"no-proxy": "localhost,127.0.0.1"` 表示不走代理的主机、域名或 IP，多个值用逗号分隔，可以使用通配符。
- `"no-proxy": "*"` 表示所有请求都不走代理。

此配置只作用于 dockerd ，详见 [Daemon proxy configuration](https://docs.docker.com/engine/daemon/proxy/)。

容器内代理（containerd） 由 `~/.docker/config.json` 配置，详见 [Use a proxy server with the Docker CLI](https://docs.docker.com/engine/cli/proxy/)。


## Docker build

{{< bar title="dockerfile" >}}

```dockerfile
ARG http_proxy="http://127.0.0.1:7897"
ARG https_proxy="http://127.0.0.1:7897"
```

构建时必须指定网络 `--network host`（默认网络是 bridge）。
