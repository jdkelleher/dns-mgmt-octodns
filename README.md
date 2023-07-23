# Manage DNS as code with [OctoDNS](https://github.com/octodns/octodns).

OctoDNS is a very elegant infrastructure as code tool for managing DNS. This repo is used to manage several domains and can be forked and configured to manage others.

This repo is configured to automatically push sync zone changes to DNS providers after pull requests are approved in GitHub. Zone changes can also be pushed manually from a local copy of the repo.

OctoDNS is written in Python and make is used to manage the virtual environment, dependencies, and zone change actions.


## Table of Contents
- [Manage DNS as code with OctoDNS.](#manage-dns-as-code-with-octodns)
  - [Table of Contents](#table-of-contents)
  - [Dependencies](#dependencies)
    - [Grab the repo](#grab-the-repo)
    - [Install dependencies in virtual environment](#install-dependencies-in-virtual-environment)
    - [Configuration](#configuration)
    - [Credentials / Tokens / Keys (aka Secret Stuff)](#credentials--tokens--keys-aka-secret-stuff)
    - [Zone Files](#zone-files)
    - [Validate](#validate)
    - [Sync (Dry Run)](#sync-dry-run)
    - [Do It](#do-it)
    - [CI/CD](#cicd)
  - [Contributing](#contributing)
  - [License and copyright](#license-and-copyright)


## Dependencies
- [OctoDNS](https://github.com/octodns/octodns)
- [Python](https://www.python.org/)
- [make](https://en.wikipedia.org/wiki/Make_(software))
- [Makefile.env](https://github.com/sio/Makefile.venv)


### Grab the repo

That's easy, just clone it.

```shell
$ git clone https://github.com/jdkelleher/dns-mgmt-octodns.git
$ cd dns-mgmt-octodns
```


### Install dependencies in virtual environment

The file `requirements.txt` contains all the Python modules needed to install OctoDNS for a given configuration. The YAML provider is built-in, but the other [providers](https://github.com/octodns/octodns#providers) are maintained in their own repositories and released as independent modules. Update or exclude version numbers as appropriate.

```shell
$ cat requirements.txt
octodns==0.9.21
octodns-cloudflare==0.0.2
$
```

At this point, both `make` and `python3` must be installed and in the PATH. To (re)install OctoDNS modules and all dependencies, simply run

```shell
$ make clean-venv
$ make venv
```


### Configuration

Customize the [`config.yaml`](config.yaml) file provided as needed. The OctoDNS repo has a plenty of [config documentation](https://github.com/octodns/octodns#config). There are also numerous webpages which explain the configuration process and options. It would be silly to replicate either here. 


### Credentials / Tokens / Keys (aka Secret Stuff)

Credentials for all of the OctoDNS [providers](https://github.com/octodns/octodns#providers) can be supplied via environment variables. This is very convenient for CI/CD piplines.

The file `.env` will be included for environment variables if it exists (no errors will be generated if it does not) Be careful as this is done via a `-include $(WORKDIR)/.env` statement parsed by `make`, it is not sourced a shell. `make` syntax must be used which does not parse single or double quotes, so values with spaces are not supported. This file should also be excluded from the repo via `.gitignore` to prevent secrets being leaked.

Example contents:

```shell
$ cat .env
# Add these as Repository secrets to enable GitHub Actions
export CLOUDFLARE_EMAIL=user@example.com
export CLOUDFLARE_TOKEN=aBunchOfNumbersAndLetters
$
```


### Zone Files

There is a script included that can be used to pull down zones from a provider into local files. It's a not very smart wrapper around `octodns-dump` that will parse a config and try to do the right thing. Use with caution for the initial zone file population.

```shell
$ make shell
. ./.venv/bin/activate && exec sh
(.venv) ./scripts/dump-zones.py --config-file ./config.yaml 
Running command: octodns-dump --config-file ./config.yaml --output-dir=./zones/ grumpydude.com. cloudflare
2023-07-22T19:38:22  [140704284960320] INFO  Manager __init__: config_file=./config.yaml (octoDNS 0.9.21)
2023-07-22T19:38:22  [140704284960320] INFO  Manager _config_executor: max_workers=10
2023-07-22T19:38:22  [140704284960320] INFO  Manager _config_include_meta: include_meta=False
2023-07-22T19:38:22  [140704284960320] INFO  Manager __init__: global_processors=[]
2023-07-22T19:38:22  [140704284960320] INFO  Manager __init__: provider=zones (octodns.provider.yaml 0.9.21)
2023-07-22T19:38:22  [140704284960320] INFO  Manager __init__: provider=cloudflare (octodns_cloudflare 0.0.2)
2023-07-22T19:38:22  [140704284960320] INFO  Manager __init__: processor=exclude-names (octodns.processor.filter 0.9.21)
2023-07-22T19:38:22  [140704284960320] INFO  Manager dump: zone=grumpydude.com., output_dir=./zones/, output_provider=None, lenient=False, split=False, sources=['cloudflare']
2023-07-22T19:38:22  [140704284960320] INFO  Manager dump: using custom YamlProvider
2023-07-22T19:38:23  [140704284960320] INFO  CloudflareProvider[cloudflare] populate:   found 14 records, exists=True
2023-07-22T19:38:23  [140704284960320] INFO  YamlProvider[dump] plan: desired=grumpydude.com.
2023-07-22T19:38:23  [140704284960320] WARNING YamlProvider[dump] root NS record supported, but no record is configured for grumpydude.com.
2023-07-22T19:38:23  [140704284960320] INFO  YamlProvider[dump] plan:   Creates=14, Updates=0, Deletes=0, Existing Records=0
2023-07-22T19:38:23  [140704284960320] INFO  YamlProvider[dump] apply: making 14 changes to grumpydude.com.
Running command: octodns-dump --config-file ./config.yaml --output-dir=./zones/ grumpydudette.com. cloudflare
2023-07-22T19:38:23  [140704284960320] INFO  Manager __init__: config_file=./config.yaml (octoDNS 0.9.21)
2023-07-22T19:38:23  [140704284960320] INFO  Manager _config_executor: max_workers=10
2023-07-22T19:38:23  [140704284960320] INFO  Manager _config_include_meta: include_meta=False
2023-07-22T19:38:23  [140704284960320] INFO  Manager __init__: global_processors=[]
2023-07-22T19:38:23  [140704284960320] INFO  Manager __init__: provider=zones (octodns.provider.yaml 0.9.21)
2023-07-22T19:38:23  [140704284960320] INFO  Manager __init__: provider=cloudflare (octodns_cloudflare 0.0.2)
2023-07-22T19:38:23  [140704284960320] INFO  Manager __init__: processor=exclude-names (octodns.processor.filter 0.9.21)
2023-07-22T19:38:23  [140704284960320] INFO  Manager dump: zone=grumpydudette.com., output_dir=./zones/, output_provider=None, lenient=False, split=False, sources=['cloudflare']
2023-07-22T19:38:23  [140704284960320] INFO  Manager dump: using custom YamlProvider
2023-07-22T19:38:24  [140704284960320] INFO  CloudflareProvider[cloudflare] populate:   found 3 records, exists=True
2023-07-22T19:38:24  [140704284960320] INFO  YamlProvider[dump] plan: desired=grumpydudette.com.
2023-07-22T19:38:24  [140704284960320] WARNING YamlProvider[dump] root NS record supported, but no record is configured for grumpydudette.com.
2023-07-22T19:38:24  [140704284960320] INFO  YamlProvider[dump] plan:   Creates=3, Updates=0, Deletes=0, Existing Records=0
2023-07-22T19:38:24  [140704284960320] INFO  YamlProvider[dump] apply: making 3 changes to grumpydudette.com.
Running command: octodns-dump --config-file ./config.yaml --output-dir=./zones/ kcrew.net. cloudflare
2023-07-22T19:38:24  [140704284960320] INFO  Manager __init__: config_file=./config.yaml (octoDNS 0.9.21)
2023-07-22T19:38:24  [140704284960320] INFO  Manager _config_executor: max_workers=10
2023-07-22T19:38:24  [140704284960320] INFO  Manager _config_include_meta: include_meta=False
2023-07-22T19:38:24  [140704284960320] INFO  Manager __init__: global_processors=[]
2023-07-22T19:38:24  [140704284960320] INFO  Manager __init__: provider=zones (octodns.provider.yaml 0.9.21)
2023-07-22T19:38:24  [140704284960320] INFO  Manager __init__: provider=cloudflare (octodns_cloudflare 0.0.2)
2023-07-22T19:38:24  [140704284960320] INFO  Manager __init__: processor=exclude-names (octodns.processor.filter 0.9.21)
2023-07-22T19:38:24  [140704284960320] INFO  Manager dump: zone=kcrew.net., output_dir=./zones/, output_provider=None, lenient=False, split=False, sources=['cloudflare']
2023-07-22T19:38:24  [140704284960320] INFO  Manager dump: using custom YamlProvider
2023-07-22T19:38:25  [140704284960320] INFO  CloudflareProvider[cloudflare] populate:   found 3 records, exists=True
2023-07-22T19:38:25  [140704284960320] INFO  YamlProvider[dump] plan: desired=kcrew.net.
2023-07-22T19:38:25  [140704284960320] WARNING YamlProvider[dump] root NS record supported, but no record is configured for kcrew.net.
2023-07-22T19:38:25  [140704284960320] INFO  YamlProvider[dump] plan:   Creates=3, Updates=0, Deletes=0, Existing Records=0
2023-07-22T19:38:25  [140704284960320] INFO  YamlProvider[dump] apply: making 3 changes to kcrew.net.
(.venv) 
(.venv) ls zones
grumpydude.com.yaml	grumpydudette.com.yaml	kcrew.net.yaml
(.venv)
```


### Validate

To validate the `config.yaml` file and any referenced local zone files, simply run

```shell
$ make validate
./.venv/bin/octodns-validate --config-file config.yaml
$
```
No errors, so everything is good.


### Sync (Dry Run)

To have OctoDNS report on all actions which need to be taken to sync any zone updates with the configured providers, simply run 

```shell
$ make sync
./.venv/bin/octodns-validate --config-file config.yaml
./.venv/bin/octodns-sync --config-file config.yaml
2023-07-22T19:14:40  [140704284960320] INFO  Manager __init__: config_file=config.yaml (octoDNS 0.9.21)
2023-07-22T19:14:40  [140704284960320] INFO  Manager _config_executor: max_workers=10
2023-07-22T19:14:40  [140704284960320] INFO  Manager _config_include_meta: include_meta=False
2023-07-22T19:14:40  [140704284960320] INFO  Manager __init__: global_processors=[]
2023-07-22T19:14:40  [140704284960320] INFO  Manager __init__: provider=zones (octodns.provider.yaml 0.9.21)
2023-07-22T19:14:40  [140704284960320] INFO  Manager __init__: provider=cloudflare (octodns_cloudflare 0.0.2)
2023-07-22T19:14:40  [140704284960320] INFO  Manager __init__: processor=exclude-names (octodns.processor.filter 0.9.21)
2023-07-22T19:14:40  [140704284960320] INFO  Manager sync: eligible_zones=[], eligible_targets=[], dry_run=True, force=False, plan_output_fh=<stdout>
2023-07-22T19:14:40  [140704284960320] INFO  Manager sync:   zone=grumpydude.com.
2023-07-22T19:14:40  [140704284960320] INFO  Manager sync:   sources=['zones'] -> targets=['cloudflare']
2023-07-22T19:14:40  [140704284960320] INFO  Manager sync:   zone=grumpydudette.com.
2023-07-22T19:14:40  [140704284960320] INFO  Manager sync:   sources=['zones'] -> targets=['cloudflare']
2023-07-22T19:14:40  [123145424785408] INFO  YamlProvider[zones] populate:   found 13 records, exists=False
2023-07-22T19:14:40  [123145424785408] INFO  CloudflareProvider[cloudflare] plan: desired=grumpydude.com.
2023-07-22T19:14:40  [123145441574912] INFO  YamlProvider[zones] populate:   found 3 records, exists=False
2023-07-22T19:14:40  [123145441574912] INFO  CloudflareProvider[cloudflare] plan: desired=grumpydudette.com.
2023-07-22T19:14:40  [140704284960320] INFO  Manager sync:   zone=kcrew.net.
2023-07-22T19:14:40  [140704284960320] INFO  Manager sync:   sources=['zones'] -> targets=['cloudflare']
2023-07-22T19:14:40  [123145458364416] INFO  YamlProvider[zones] populate:   found 3 records, exists=False
2023-07-22T19:14:40  [123145458364416] INFO  CloudflareProvider[cloudflare] plan: desired=kcrew.net.
2023-07-22T19:14:40  [123145441574912] INFO  CloudflareProvider[cloudflare] populate:   found 3 records, exists=True
2023-07-22T19:14:40  [123145441574912] INFO  CloudflareProvider[cloudflare] plan:   No changes
2023-07-22T19:14:40  [123145424785408] INFO  CloudflareProvider[cloudflare] populate:   found 14 records, exists=True
2023-07-22T19:14:40  [123145424785408] INFO  CloudflareProvider[cloudflare] plan:   Creates=0, Updates=1, Deletes=0, Existing Records=13
2023-07-22T19:14:40  [123145458364416] INFO  CloudflareProvider[cloudflare] populate:   found 3 records, exists=True
2023-07-22T19:14:40  [123145458364416] INFO  CloudflareProvider[cloudflare] plan:   No changes
2023-07-22T19:14:40  [140704284960320] INFO  Plan 
********************************************************************************
* grumpydude.com.
********************************************************************************
* cloudflare (CloudflareProvider)
*   Update
*     <TxtRecord TXT 300, test.grumpydude.com., ['update 2 to test txt entry']> ->
*     <TxtRecord TXT 300, test.grumpydude.com., ['update 3 to test txt entry']> (zones)
*   Summary: Creates=0, Updates=1, Deletes=0, Existing Records=13
********************************************************************************


$
```
Here you can see that `make sync` runs `make validate` as a dependency and an update is planned to a TXT record created for testing.


### Do It

stuff ...

```shell
$ make doit
./.venv/bin/octodns-validate --config-file config.yaml
./.venv/bin/octodns-sync --config-file config.yaml --doit
2023-07-22T19:17:51  [140704284960320] INFO  Manager __init__: config_file=config.yaml (octoDNS 0.9.21)
2023-07-22T19:17:51  [140704284960320] INFO  Manager _config_executor: max_workers=10
2023-07-22T19:17:51  [140704284960320] INFO  Manager _config_include_meta: include_meta=False
2023-07-22T19:17:51  [140704284960320] INFO  Manager __init__: global_processors=[]
2023-07-22T19:17:51  [140704284960320] INFO  Manager __init__: provider=zones (octodns.provider.yaml 0.9.21)
2023-07-22T19:17:51  [140704284960320] INFO  Manager __init__: provider=cloudflare (octodns_cloudflare 0.0.2)
2023-07-22T19:17:51  [140704284960320] INFO  Manager __init__: processor=exclude-names (octodns.processor.filter 0.9.21)
2023-07-22T19:17:51  [140704284960320] INFO  Manager sync: eligible_zones=[], eligible_targets=[], dry_run=False, force=False, plan_output_fh=<stdout>
2023-07-22T19:17:51  [140704284960320] INFO  Manager sync:   zone=grumpydude.com.
2023-07-22T19:17:51  [140704284960320] INFO  Manager sync:   sources=['zones'] -> targets=['cloudflare']
2023-07-22T19:17:51  [140704284960320] INFO  Manager sync:   zone=grumpydudette.com.
2023-07-22T19:17:51  [140704284960320] INFO  Manager sync:   sources=['zones'] -> targets=['cloudflare']
2023-07-22T19:17:51  [123145347317760] INFO  YamlProvider[zones] populate:   found 3 records, exists=False
2023-07-22T19:17:51  [123145347317760] INFO  CloudflareProvider[cloudflare] plan: desired=grumpydudette.com.
2023-07-22T19:17:51  [123145330528256] INFO  YamlProvider[zones] populate:   found 13 records, exists=False
2023-07-22T19:17:51  [123145330528256] INFO  CloudflareProvider[cloudflare] plan: desired=grumpydude.com.
2023-07-22T19:17:51  [140704284960320] INFO  Manager sync:   zone=kcrew.net.
2023-07-22T19:17:51  [140704284960320] INFO  Manager sync:   sources=['zones'] -> targets=['cloudflare']
2023-07-22T19:17:51  [123145364107264] INFO  YamlProvider[zones] populate:   found 3 records, exists=False
2023-07-22T19:17:51  [123145364107264] INFO  CloudflareProvider[cloudflare] plan: desired=kcrew.net.
2023-07-22T19:17:52  [123145364107264] INFO  CloudflareProvider[cloudflare] populate:   found 3 records, exists=True
2023-07-22T19:17:52  [123145364107264] INFO  CloudflareProvider[cloudflare] plan:   No changes
2023-07-22T19:17:52  [123145347317760] INFO  CloudflareProvider[cloudflare] populate:   found 3 records, exists=True
2023-07-22T19:17:52  [123145347317760] INFO  CloudflareProvider[cloudflare] plan:   No changes
2023-07-22T19:17:52  [123145330528256] INFO  CloudflareProvider[cloudflare] populate:   found 14 records, exists=True
2023-07-22T19:17:52  [123145330528256] INFO  CloudflareProvider[cloudflare] plan:   Creates=0, Updates=1, Deletes=0, Existing Records=13
2023-07-22T19:17:52  [140704284960320] INFO  Plan 
********************************************************************************
* grumpydude.com.
********************************************************************************
* cloudflare (CloudflareProvider)
*   Update
*     <TxtRecord TXT 300, test.grumpydude.com., ['update 2 to test txt entry']> ->
*     <TxtRecord TXT 300, test.grumpydude.com., ['update 3 to test txt entry']> (zones)
*   Summary: Creates=0, Updates=1, Deletes=0, Existing Records=13
********************************************************************************


2023-07-22T19:17:52  [140704284960320] INFO  CloudflareProvider[cloudflare] apply: making 1 changes to grumpydude.com.
2023-07-22T19:17:52  [140704284960320] INFO  Manager sync:   1 total changes
$
```

Here you can see that `make doit` also runs `make validate` as a dependency as caution is best. The update plan that was shown by `make sync` has been executed and change can be validated with `dig` like so

```shell
$ dig -t txt test.grumpydude.com

; <<>> DiG 9.10.6 <<>> -t txt test.grumpydude.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 6901
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;test.grumpydude.com.		IN	TXT

;; ANSWER SECTION:
test.grumpydude.com.	300	IN	TXT	"update 3 to test txt entry"

;; Query time: 29 msec
;; SERVER: 10.13.13.1#53(10.13.13.1)
;; WHEN: Sat Jul 22 19:22:27 CDT 2023
;; MSG SIZE  rcvd: 106
$
```

OctoDNS has built-in protection to make too many records are not added/deleted/updated in a single go. If an error message is displayed and the changes are valid, the checks can be bypassed with `make force` option.


### CI/CD

There are many options to run OctoDNS as part of a CI/CD pipeline. This repo includes a workflow, [`deploy.yaml`](.github/workflows/deploy.yaml) for an action to run on a push or pull request to main. It will deploy and configure a docker container to execute `make doit`. All runs of this workflow can be found [here](https://github.com/jdkelleher/dns-mgmt-octodns/actions/workflows/deploy.yaml). 

GitHub Actions documentation may be found [here](https://docs.github.com/en/actions).


## Contributing

Would be greatly appreciate. Please open [Issues](https://github.com/jdkelleher/dns-mgmt-octodns/issues) and/or submit [Pull requests](https://github.com/jdkelleher/dns-mgmt-octodns/pulls).


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
