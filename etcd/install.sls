# -*- coding: utf-8 -*-
# vim: ft=yaml
{% from "etcd/map.jinja" import etcd with context -%}

  {% if etcd.lookup.manage_users == true %}
etcd-user-group-home:
  group.present:
    - name: {{ etcd.lookup.group or 'etcd' }}
    - system: True
  user.present:
    - name: {{ etcd.lookup.user or 'etcd' }}
    - gid_from_name: true
    - home: {{ etcd.lookup.prefix }}
    - require_in:
      - file: etcd-user-envfile
  {% endif %}

# Cleanup first
etcd-remove-prev-archive:
  file.absent:
    - name: {{ etcd.lookup.tmpdir }}{{ etcd.dl.archive_name }}
    - require_in:
      - etcd-extract-dirs

etcd-extract-dirs:
  file.directory:
    - makedirs: True
    - mode: '0755'
    - require_in:
      - etcd-download-archive
    - names:
      - {{ etcd.lookup.tmpdir }}
      - {{ etcd.lookup.prefix }}
      - {{ etcd.lookup.datadir }}
  {% if etcd.lookup.manage_users %}
    - user: {{ etcd.lookup.user or 'etcd' }}
    - group: {{ etcd.lookup.group or 'etcd' }}
    - recurse:
      - user
      - group
    - require_in:
      - file: etcd-user-envfile

etcd-user-envfile:
  file.managed:
    - name: {{ etcd.lookup.prefix }}/env4etcd.sh
    - source: salt://etcd/files/env4etcd.sh
    - template: jinja
    - mode: 644
    - user: {{ etcd.lookup.user or 'etcd' }}
    - group: {{ etcd.lookup.group or 'etcd' }}
    - context:
      etcd: {{ etcd|json }}

  {% endif %}

{% if etcd.lookup.use_upstream_repo|lower == 'true' %}

etcd-download-archive:
  cmd.run:
    - name: curl {{ etcd.dl.opts }} -o '{{ etcd.lookup.tmpdir }}{{ etcd.dl.archive_name }}' {{ etcd.dl.src_url }}
    - retry:
        attempts: {{ etcd.dl.retries }}
        interval: {{ etcd.dl.interval }}
    - unless: test -f {{ etcd.lookup.realhome }}/{{ etcd.lookup.command }}

    {%- if etcd.lookup.src_hashsum and grains['saltversioninfo'] <= [2016, 11, 6] %}
etcd-check-archive-hash:
   module.run:
     - name: file.check_hash
     - path: '{{ etcd.lookup.tmpdir }}/{{ etcd.dl.archive_name }}'
     - file_hash: {{ etcd.lookup.src_hashsum }}
     - onchanges:
       - cmd: etcd-download-archive
     - require_in:
       - archive: etcd-install
    {%- endif %}

{% endif %}

etcd-install:
{% if grains.os == 'MacOS' and etcd.lookup.use_upstream_repo|lower == 'homebrew' %}
  pkg.installed:
    - name: {{ etcd.lookup.pkg }}
    - version: {{ etcd.lookup.version }}
{% elif etcd.lookup.use_upstream_repo|lower == 'true' %}
  archive.extracted:
    - source: 'file://{{ etcd.lookup.tmpdir }}/{{ etcd.dl.archive_name }}'
    - name: '{{ etcd.lookup.prefix }}'
    - archive_format: {{ etcd.dl.format.split('.')[0] }}
    - unless: test -f {{ etcd.lookup.realhome }}{{ etcd.lookup.command }}
    - watch_in:
      - service: etcd_{{ etcd.lookup.service }}_running
    - onchanges:
      - cmd: etcd-download-archive
    {%- if etcd.lookup.src_hashurl and grains['saltversioninfo'] > [2016, 11, 6] %}
    - source_hash: {{ etcd.lookup.src_hashurl }}
    {%- endif %}

{% endif %}

