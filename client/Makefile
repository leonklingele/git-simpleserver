GIT_SIMPLESERVER_DIR = $(HOME)/.git-simpleserver
BIN_DIR = /usr/local/bin
INSTALL = install

install: config
	ln -s $(CURDIR)/git-simpleserver $(BIN_DIR)
	ln -s $(BIN_DIR)/git-simpleserver $(BIN_DIR)/git-ss

uninstall:
	rm $(BIN_DIR)/git-simpleserver
	rm $(BIN_DIR)/git-ss

config:
	@if [ ! -f "$(GIT_SIMPLESERVER_DIR)/config.yaml" ]; then \
		OLD_UMASK=$(shell echo `umask`) ; \
		umask 077 ; \
		mkdir -p $(GIT_SIMPLESERVER_DIR) ; \
		$(INSTALL) -c -m 0600 config.yaml.in $(GIT_SIMPLESERVER_DIR)/config.yaml ; \
		umask $(OLD_UMASK) > /dev/null ; \
	fi

.PHONY: install config
