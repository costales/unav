#!/usr/bin/make -f
# -*- makefile -*-

POT_FILE=po/unav.pot

HTML_JS_FILE=nav/index.html
HTML_STRINGS_FILE=nav/index.html.strings
$(HTML_STRINGS_FILE): nav/index.html
	grep -Po 'data-localize=([^>]*)' $< > $@
$(HTML_STRINGS_FILE).h: $(HTML_STRINGS_FILE)
	intltool-extract --type=gettext/quoted $<

QML_FILES=$(shell find -iname *.qml -printf '%P\n')
JS_FILES=$(wildcard nav/class/*.js qml/js/*.js)

I18N_FILES=$(sort $(QML_FILES) $(JS_FILES) $(HTML_JS_FILE) $(HTML_STRINGS_FILE).h)

$(POT_FILE): $(I18N_FILES)
	xgettext -o $@ --from-code=UTF-8 -C --qt --add-comments=TRANSLATORS \
		--keyword=tr --keyword=tr:1,2 --keyword=t --keyword=N_ \
		--package-name=unav -D . $^

PO_FILES=$(wildcard po/*.po)

MO_ROOT=nav/locales/mo
MO_FILES=$(PO_FILES:po%.po=$(MO_ROOT)%/LC_MESSAGES/unav.mo)
$(MO_ROOT)/%/LC_MESSAGES/unav.mo: po/%.po
	mkdir -p `dirname $@`
	msgfmt -o $@ $<

JSON_ROOT=nav/locales/json
JSON_FILES=$(PO_FILES:po/%po=$(JSON_ROOT)/messages-%json)
$(JSON_ROOT)/messages-%.json: po/%.po
	python nav/locales/3rdparty/po2json.py $<
	mv $(subst .po,.json,$<) $@
	cp $@ $(subst @,-,$(subst _,-,$@)) || true

translations: $(MO_FILES) $(JSON_FILES)

APPNAME=$(shell grep -Po '"name":\s*"([^>]*)"' manifest.json | cut -d\" -f4)
APPVERSION=$(shell grep -Po '"version":\s*"([^>]*)"' manifest.json | cut -d\" -f4)
APPARCH=all
CLICKPKG=$(APPNAME)_$(APPVERSION)_$(APPARCH).click
$(CLICKPKG): translations
	click build -I Makefile -I "*.click" -I po -I 3rdparty -I README .
click: $(CLICKPKG)

clean:
	rm -rf $(HTML_STRINGS_FILE) $(HTML_STRINGS_FILE).h *.click
release:
	# Preserve API keys
	/home/costales/Code/unav/release.sh
