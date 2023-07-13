# Manage DNS as code with [OctoDNS](https://github.com/octodns/octodns).

OctoDNS is a very elegant infrastructure as code tool for managing DNS. This repo is used to manage several domains and can be forked and configured to manage others.

This repo is configured to automatically push sync zone changes to DNS providers after pull requests are approved in GitHub. Zone changes can also be pushed manually from a local copy of the repo.

OctoDNS is written in Python and make is used to manage the virtual environment, dependencies, and zone change actions.


## Dependencies
- [OctoDNS](https://github.com/octodns/octodns)
- [Python](https://www.python.org/)
- [make](https://en.wikipedia.org/wiki/Make_(software))
- [Makefile.env](https://github.com/sio/Makefile.venv)



## Getting Started

stuff ...


### Grab the repo

That's easy, just clone it.

```shell
$ git clone https://github.com/jdkelleher/dns-mgmt-octodns.git
$ cd dns-mgmt-octodns
```


### Install dependencies in virtual environment

The file `requirements.txt` contains all the Python modules needed to install OctoDNS for a given configuration. The YAML provider is built-in, but the other [providers](https://github.com/octodns/octodns#providers) are maintained in their own repositories and released as independent modules.

```shell
$ cat requirements.txt
octodns==0.9.21
octodns-cloudflare==0.0.2
$
```

To (re)install OctoDNS modules and all dependencies, simply run

```shell
$ make clean-venv
$ make venv
```

### Secrets / Tokens

stuff ...


```shell
$ cat .env
# Add these as Repository secrets to enable GitHub actions
export CLOUDFLARE_EMAIL="ENTER EMAIL"
export CLOUDFLARE_TOKEN="ENTER TOKEN"
$
```

### Config

stuff ...

`config.yaml`
```yaml
---
manager:
  max_workers: 10

providers:
  zones:
    class: octodns.provider.yaml.YamlProvider
    directory: ./zones
    default_ttl: 300
    enforce_order: true
  cloudflare:
    class: octodns_cloudflare.CloudflareProvider
    email: env/CLOUDFLARE_EMAIL
    token: env/CLOUDFLARE_TOKEN

zones:
  example.com.:
    sources:
      - zones
    targets:
      - cloudflare
```

`zones/example.com.yaml`
```yaml
---
? ''
: - octodns:
      cloudflare:
        proxied: false
    ttl: 300
    type: A
    value: 10.0.0.10
  - ttl: 300
    type: MX
    values:
    - exchange: mx1.example.com.
      preference: 1
  - ttl: 300
    type: TXT
    value: v=spf1 a mx ~all

mx1:
  octodns:
    cloudflare:
      proxied: false
  ttl: 300
  type: A
  value: 10.0.0.5

test:
- ttl: 300
  type: TXT
  value: just a test txt entry

www:
  octodns:
    cloudflare:
      proxied: false
  ttl: 300
  type: A
  value: 10.0.0.10

```

### Validate

To validate the `config.yaml` and any zone changes, simply run

```shell
$ make validate
```

### Sync (Dry Run)

stuff ...

```shell
$ make sync
```


### Do It

stuff ...

```shell
$ make doit
```

OctoDNS has built-in protection to make too many records are not added/deleted/updated in a single go. If you are sure the changes are valid, the checks can be bypassed with the `--force` option.

```shell
$ make force
```


## Contributing

Would be greatly appreciate ...


## License and copyright

Copyright 2023 Jason D. Kelleher

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
