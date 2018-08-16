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
	cp -raf *.service $(DESTDIR)/usr/lib/systemd/system/
	chmod 0644 $(DESTDIR)/usr/lib/systemd/system/onedrive*.service
	
onedrive: $(SOURCES)
	$(DC) $(DFLAGS) $(SOURCES)

onedrive.service:
	sed "s|@PREFIX@|$(PREFIX)|g" systemd.units/onedrive.service.in > onedrive.service
	sed "s|@PREFIX@|$(PREFIX)|g" systemd.units/onedrive@.service.in > onedrive@.service

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/onedrive
	rm -f $(DESTDIR)/usr/lib/systemd/system/onedrive.service
	rm -f $(DESTDIR)/usr/lib/systemd/system/onedrive@.service
	rm -f $(DESTDIR)/etc/logrotate.d/onedrive

