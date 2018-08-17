DC = dmd
DFLAGS = -g -ofonedrive -O -L-lcurl -L-lsqlite3 -L-ldl -J.
PREFIX = /usr/local

SOURCES = \
	src/config.d \
	src/itemdb.d \
	src/log.d \
	src/main.d \
	src/monitor.d \
	src/onedrive.d \
	src/qxor.d \
	src/selective.d \
	src/sqlite.d \
	src/sync.d \
	src/upload.d \
	src/util.d \
	src/progress.d

all: onedrive onedrive.service

clean:
	rm -f onedrive onedrive.o onedrive.service onedrive@.service

install: all
	mkdir -p $(DESTDIR)/var/log/onedrive
	chown root.users $(DESTDIR)/var/log/onedrive
	chmod 0775 $(DESTDIR)/var/log/onedrive
	install -D onedrive $(DESTDIR)$(PREFIX)/bin/onedrive
	install -D -m 644 logrotate/onedrive.logrotate $(DESTDIR)/etc/logrotate.d/onedrive
	cp -raf *.service $(DESTDIR)/etc/systemd/system/
	chmod 0644 $(DESTDIR)/etc/systemd/system/onedrive*.service
	cp -af sudoers.d/onedrive /etc/sudoers.d/onedrive
	chown root.root /etc/sudoers.d/onedrive
	chmod 0440 /etc/sudoers.d/onedrive

onedrive: version $(SOURCES)
	$(DC) $(DFLAGS) $(SOURCES)

onedrive.service:
	sed "s|@PREFIX@|$(PREFIX)|g" systemd.units/onedrive.service.in > onedrive.service
	sed "s|@PREFIX@|$(PREFIX)|g" systemd.units/onedrive@.service.in > onedrive@.service

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/onedrive
	rm -f $(DESTDIR)/etc/systemd/system/onedrive.service
	rm -f $(DESTDIR)/etc/systemd/system/onedrive@.service
	rm -f $(DESTDIR)/etc/logrotate.d/onedrive
	rm -f /etc/sudoers.d/onedrive

version: .git/HEAD .git/index
	rm -f version
	echo $(shell git describe --tags) >version
