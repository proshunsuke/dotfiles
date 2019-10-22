ANSIBLE_PLAYBOOK_CMD := ansible-playbook
HOST_NAME            := $(or $(HOST_NAME),sample)
INVENTORY            := hosts/$(HOST_NAME)/inventory
PLAYBOOK_NAME        := $(or $(HOST_NAME),sample)
PLAYBOOK             := playbooks/$(PLAYBOOK_NAME).yml
DRY_RUN_OPT          := --check
SYNTAX_CHECK_OPT     := --syntax-check
CONNECTION           := local

ANSIBLE_LINT_CMD     := ansible-lint
LINT_PATTERN         := playbooks/**/*.yml

RSPEC_CMD            := rspec

.PHONY: help all lint dry-run syntax-check apply test ci

help: ## ヘルプの表示
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z%\/\._-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: lint apply test ## lint, apply, test

ci: apply test ## apply, test

lint: ## (ansible) lint を走らす
	$(ANSIBLE_LINT_CMD) $(LINT_PATTERN)

dry-run: ## (ansible) dry-run
	$(ANSIBLE_PLAYBOOK_CMD) -i $(INVENTORY) -c $(CONNECTION) $(DRY_RUN_OPT) $(PLAYBOOK)

syntax-check: ## (ansible) 構文チェックを行う
	$(ANSIBLE_PLAYBOOK_CMD) -i $(INVENTORY) -c $(CONNECTION) $(SYNTAX_CHECK_OPT) $(PLAYBOOK)

ansible: ## ansibleをインストール see: https://github.com/kewlfft/ansible-aur
	sh scripts/$(HOST_NAME)/install_ansible.sh
	mkdir -p ~/.ansible/plugins/modules
ifeq (,$(wildcard ~/.ansible/plugins/modules/aur))
	git clone https://github.com/kewlfft/ansible-aur.git ~/.ansible/plugins/modules/aur
endif

apply: ansible syntax-check ## (ansible) 変更を適用する
	$(ANSIBLE_PLAYBOOK_CMD) -i $(INVENTORY) -c $(CONNECTION) $(PLAYBOOK)

test: ## (rspec) テストを走らす
ifneq (,$(wildcard spec/$(HOST_NAME)/$(PLAYBOOK_NAME)_spec.rb))
	$(RSPEC_CMD) spec/$(HOST_NAME)/$(PLAYBOOK_NAME)_spec.rb
else
	@echo "serverspec is dose not exist."
endif

-include makefiles/*.mk
