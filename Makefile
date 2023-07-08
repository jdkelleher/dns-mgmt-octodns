

# This depends on Makefile.env which can be found here - https://github.com/sio/Makefile.venv/blob/master/Makefile.venv
#
# wget https://raw.githubusercontent.com/sio/Makefile.venv/master/Makefile.venv

# $(WORKDIR)/requirements.txt must contain all modules needed by octodns
#
# Example contents:
# 	octodns==0.9.21
# 	octodns-cloudflare==0.0.2

# $(WORKDIR)/.env will be sourced for environment variables if it exists
#
# Example contents:
# 	export CLOUDFLARE_EMAIL="user@example.com"
# 	export CLOUDFLARE_TOKEN="aBunchOfNumbers"


.PHONY: doit 
doit: venv validate
	@[ -f $(WORKDIR)/.env ] && . $(WORKDIR)/.env; $(VENV)/octodns-sync --config-file config.yaml --doit


.PHONY: force 
force: venv validate
	@[ -f $(WORKDIR)/.env ] && . $(WORKDIR)/.env; $(VENV)/octodns-sync --config-file config.yaml --doit --force


.PHONY: interactive
interactive: venv
	@[ -f $(WORKDIR)/.env ] && . $(WORKDIR)/.env; . $(VENV)/activate && exec $(notdir $(SHELL))


.PHONY: sync
sync: venv validate
	@# . $(WORKDIR)/.env ; $(VENV)/octodns-sync --config-file config.yaml
	@[ -f $(WORKDIR)/.env ] && . $(WORKDIR)/.env; $(VENV)/octodns-sync --config-file config.yaml



.PHONY: validate
validate: venv
	@# . $(WORKDIR)/.env ; $(VENV)/octodns-validate --config-file config.yaml
	@[ -f $(WORKDIR)/.env ] && . $(WORKDIR)/.env; $(VENV)/octodns-validate --config-file config.yaml





include Makefile.venv



