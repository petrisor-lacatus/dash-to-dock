# Basic Makefile

UUID = dash-to-dock@micxgx.gmail.com
BASE_MODULES = extension.js stylesheet.css metadata.json COPYING README.md
EXTRA_MODULES = dockedDash.js intellihide.js myDash.js convenience.js prefs.js
EXTRA_MEDIA = one.svg two.svg three.svg four.svg one_rtl.svg two_rtl.svg three_rtl.svg four_rtl.svg
TOLOCALIZE =  prefs.js
MSGSRC = $(wildcard po/*.po)
INSTALLBASE = ~/.local/share/gnome-shell/extensions
INSTALLNAME = dash-to-dock@micxgx.gmail.com

# The command line passed variable VERSION is used to set the version string 
# in the metadata and in the generated zip-file. If no VERSION is passed, the
# current commit SHA1 is used as version number in the metadata while the
# generated zip file has no string attached.
ifdef VERSION
	VSTRING = _v$(VERSION)
else
	VERSION = $(shell git rev-parse HEAD)
	VSTRING =
endif

all: extension

clean:
	rm -f ./schemas/gschemas.compiled

extension: ./schemas/gschemas.compiled $(MSGSRC:.po=.mo)

./schemas/gschemas.compiled: ./schemas/org.gnome.shell.extensions.dash-to-dock.gschema.xml
	glib-compile-schemas ./schemas/

potfile: ./po/dashtodock.pot

mergepo: potfile
	for l in $(MSGSRC); do \
		msgmerge -U $$l ./po/dashtodock.pot; \
	done;

./po/dashtodock.pot: $(TOLOCALIZE)
	mkdir -p po
	xgettext -k_ -kN_ -o po/dashtodock.pot --package-name "Dash to Dock" $(TOLOCALIZE)

./po/%.mo: ./po/%.po
	msgfmt -c $< -o $@

install: install-local

install-local: _build
	rm -rf $(INSTALLBASE)/$(INSTALLNAME)
	mkdir -p $(INSTALLBASE)/$(INSTALLNAME)
	cp -r ./_build/* $(INSTALLBASE)/$(INSTALLNAME)/
	-rm -fR _build
	echo done

zip-file: _build
	cd _build ; \
	zip -qr "$(UUID)$(VSTRING).zip" .
	mv _build/$(UUID)$(VSTRING).zip ./
	-rm -fR _build

_build: all
	-rm -fR ./_build
	mkdir -p _build
	cp $(BASE_MODULES) $(EXTRA_MODULES) _build
	mkdir -p _build/media
	cd media ; cp $(EXTRA_MEDIA) ../_build/media/
	mkdir -p _build/schemas
	cp schemas/*.xml _build/schemas/
	cp schemas/gschemas.compiled _build/schemas/
	mkdir -p _build/locale
	for l in $(MSGSRC:.po=.mo) ; do \
		lf=_build/locale/`basename $$l .mo`; \
		mkdir -p $$lf; \
		mkdir -p $$lf/LC_MESSAGES; \
		cp $$l $$lf/LC_MESSAGES/dashtodock.mo; \
	done;
	sed -i 's/"version": 0/"version": "$(VERSION)"/'  _build/metadata.json;
