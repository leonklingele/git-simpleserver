GIT_HOME = /home/git

install:
	@if [ -z "$(NON_INTERACTIVE)" ]; then \
		echo "User '$(GIT_USER)', is that correct? Press any key to continue, Ctrl + C to abort" ; \
		read -r CONTINUE ; \
	fi
	@echo "Installing.."
	@sudo adduser \
		--gecos Git \
		--disabled-password \
		--home $(GIT_HOME) \
		--shell $(GIT_HOME)/shell \
		-- git || echo "User 'git' already exists"
	mkdir -p $(GIT_HOME)/repos/$(GIT_USER)
	mkdir -p $(GIT_HOME)/.ssh
	@if [ ! -f "$(GIT_HOME)/.ssh/authorized_keys" ]; then \
		cp --no-clobber authorized_keys "$(GIT_HOME)/.ssh/authorized_keys" ; \
		sed -i 's/"GIT_USER=%s"/"GIT_USER=$(GIT_USER)"/' "$(GIT_HOME)/.ssh/authorized_keys" ; \
	fi
	@if [ ! -f "$(GIT_HOME)/shell" ]; then \
		ln -s $(CURDIR)/git-shell-commands $(GIT_HOME) ; \
		ln -s $(CURDIR)/shell $(GIT_HOME) ; \
		chown -R git: $(GIT_HOME) ; \
	fi

uninstall:
	rm $(GIT_HOME)/git-shell-commands
	rm $(GIT_HOME)/shell

.PHONY: install uninstall
