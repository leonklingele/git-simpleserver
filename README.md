# Git Simple Server — Securely manage your own Git server

[![Build Status](https://travis-ci.org/leonklingele/git-simpleserver.svg?branch=master)](https://travis-ci.org/leonklingele/git-simpleserver)

Git Simple Server (abbreviated "git ss") makes it easy to manage your Git repos on your own server from the command line. It's super lightweight, secure and only requires a shell, `git` and `ssh`.
It has an integrated user management, making it simple to manage read and write permissions on a per-user, per-repo basis.

![demo](https://www.leonklingele.de/git-simpleserver/demo.gif?20170213)

### Create a new repo on your server..

```sh
$ git ss repo create server-config-nginx
Repo 'server-config-nginx' was created successfully. Track it as remote 'origin' via:
 $ git remote add origin git@leonklingele.de:leon/server-config-nginx
 $ git remote set-url origin git@leonklingele.de:leon/server-config-nginx
```

### ..and optionally grant other users access to it

```sh
$ git ss repo access server-config-nginx -rw alice
$ git ss repo access server-config-nginx -r bob

# Oops, "alice" only needs read access, but "bob" should no longer have access at all
$ git ss repo access server-config-nginx -r alice
$ git ss repo access server-config-nginx -rm bob
```

### List repos

#### List your own repos

```sh
$ git ss repo list
server-config-nginx
my-secrets
this-one-awesome-project
```

#### List all users who can access a certain repo

```sh
$ git ss repo info server-config-nginx
Users with read access:
  leon
  alice
Users with write access:
  leon
```

### Create / modify users (admin only)

#### List all users (admin only)

```sh
$ git ss user list
alice
bob
leon
```

#### Create a new user (admin only)

```sh
$ git ss user create charlie
Please paste the SSH public key for user 'charlie'. Confirm by pressing the 'Enter' key.
> ssh-rsa ..
User 'charlie' was created successfully
```

#### Delete a user (admin only)

```sh
$ git ss user delete charlie
Do you really want to delete user 'charlie'? Please answer with YES or NO
> YES
User 'charlie' was deleted successfully
```

#### List all repos a user has access to (admin only)

```sh
$ git ss user info leon
User 'leon' has read access to:
  leon/server-config-nginx
  leon/my-secrets
  leon/this-one-awesome-project
  alice/golang-is-awesome-notes
  alice/homework
User 'leon' has write access to:
  leon/server-config-nginx
  leon/my-secrets
  leon/this-one-awesome-project
```

# Installation

First, install the dependencies (most likely you already have them):

```sh
apt-get install git ssh sed grep gawk
```

This app consists of a server and a client part.
On your server, run:

```sh
$ $EDITOR /etc/ssh/sshd_config
# Set `PermitUserEnvironment yes`
# Add these lines to the very end of the file (important):
Match User git
	PasswordAuthentication no
	PubkeyAuthentication yes
	AcceptEnv GIT_SS_REMOTE_VERSION
	AllowAgentForwarding no
	AllowTcpForwarding no
	PermitTTY no
	X11Forwarding no
# Nothing else should be below the "Match User git" block
$ /etc/init.d/ssh reload
$ cd /usr/local/etc # other users must have read (no write!) access to that folder!
$ git clone https://github.com/leonklingele/git-simpleserver
$ cd git-simpleserver/server
# Choose a username you want to store your repos under, e.g. leon
$ GIT_USER="your-user" make install
# There's one last step:
$ $EDITOR /home/git/.ssh/authorized_keys
# Set "your-ssh-public-key" to your ssh public key, e.g. ssh-rsa AAAAB3N.. you@your-machine
# Full line example: environment="GIT_USER=leon",environment="GIT_ADMIN=true" ssh-rsa AAAAB3N.. you@your-machine
# Save. Enjoy. Now install the client.
```

On your client, run:

```sh
$ git clone https://github.com/leonklingele/git-simpleserver
$ cd git-simpleserver/client
$ make install
$ $EDITOR $HOME/.git-simpleserver/config.yaml
# Set 'ssh_server' to point to your server
# Don't modify 'ssh_user'
```

# Code review: How to manage pull requests

Looking for a way to manage pull requests for your repositories? git-simpleserver loves [git-appraise](https://github.com/google/git-appraise). It's awesome!

# How it works

Normally when logging in into a remote server via `ssh`, you'll get an interactive shell (most likely a `bash`). That's where you type in your fancy commands. Linux let's you define a custom shell to use (see `man chsh`). Instead of `bash`, you can for example define any script (`bash`, `sh`, `python`, ..) as your shell. Upon successful login, this script is executed and can control which commands you are allowed to run and which not.
If `git-simpleserver` is set up on your server and you successfully authenticated as user `git` using your ssh key, a [special shell](./server/shell) is launched. This shell only allows you to run a small number of commands, dedicated to managing your Git repos and Git users.
Now you're logged in as user `git`, but how does `git-simpleserver`'s user management work then? Well, that's another cool feature of OpenSSH: For each public key in `authorized_keys` you can define custom env vars which get set when this public key is used to log in. `git-simpleserver` connects a `GIT_USER` environment variable to each public key. Think of `GIT_USER` as a virtual user name, similar, but still different to the ssh user (`git`). Using `GIT_USER` we know who has logged in and can restrict read and write permissions.
No one can access your repos, unless you explicitly granted permissions to that person via `git ss user add` or the `.ssh/authorized_keys` file.

# Contact

Want to share something confidentially? Use my Git email address and this PGP key:
```pgp
PGP Key ID: 31EEC211 / 0x0C8AF48831EEC211
PGP Key fingerprint: B231 B273 70B7 A050 1CBD  992B 0C8A F488 31EE C211
```
