# services

run web services on purr via docker-compose.

## installation

this repo is meant to be cloned into `/root/purr.services` -- this path is hardcoded into the `.env` file.

```bash
# git clone git@github.com:Moomers/purr.services.git /root/purr.services
```

after cloning, run `install.sh` to set up the systemd service, called `compose`.

```bash
$ cd ~/repos/compose.services
$ ./install.sh
```

## usage

control the service with `systemctl`:

```bash
$ systemctl --user <status|start|stop|reload> compose
```

to view logs, use `journalctl`:

```bash
$ journalctl --user -f -u compose
```
