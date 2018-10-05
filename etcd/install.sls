# -*- coding: utf-8 -*-
# vim: ft=yaml
{% from "etcd/map.jinja" import etcd with context -%}

  {% if etcd.manage_users == true %}
etcd-user-group-home:
  group.present:
    - name: {{ etcd.group or 'etcd' }}
    - system: True
  user.present:
    - name: {{ etcd.user or 'etcd' }}
    - gid_from_name: true
    - home: {{ etcd.prefix }}
    - require_in:
      - file: etcd-user-envfile
  {% endif %}

# Cleanup first
etcd-remove-prev-archive:
  file.absent:
    - name: {{ etcd.tmpdir }}{{ etcd.dl.archive_name }}
    - require_in:
      - etcd-extract-dirs

etcd-extract-dirs:
  file.directory:
    - makedirs: True
    - mode: '0775'
    - require_in:
      - etcd-download-archive
    - names:
      - {{ etcd.tmpdir }}
      - {{ etcd.prefix }}
      - {{ etcd.datadir }}
  {% if etcd.manage_users %}
    - user: {{ etcd.user or 'etcd' }}
    - group: {{ etcd.group or 'etcd' }}
    - recurse:
      - user
      - group
    - require_in:
      - file: etcd-user-envfile

etcd-user-envfile:
  file.managed:
    - name: {{ etcd.datadir }}configenv
    - source: salt://etcd/files/configenv.jinja
    - template: jinja
    - mode: 644
    - user: {{ etcd.user or 'etcd' }}
    - group: {{ etcd.group or 'etcd' }}
    - context:
      etcd: {{ etcd|json }}

  {% endif %}

etcd-download-archive:
  cmd.run:
    - name: curl {{ etcd.dl.opts }} -o '{{ etcd.tmpdir }}{{ etcd.dl.archive_name }}' {{ etcd.dl.src_url }}
    - retry:
        attempts: {{ etcd.dl.retries }}
        interval: {{ etcd.dl.interval }}
    - unless: test -f {{ etcd.realhome }}/{{ etcd.command }}

    {%- if etcd.src_hashsum and grains['saltversioninfo'] <= [2016, 11, 6] %}
etcd-check-archive-hash:
   module.run:
     - name: file.check_hash
     - path: '{{ etcd.tmpdir }}/{{ etcd.dl.archive_name }}'
     - file_hash: {{ etcd.src_hashsum }}
     - onchanges:
       - cmd: etcd-download-archive
     - require_in:
       - archive: etcd-install
    {%- endif %}

etcd-install:
  archive.extracted:
    - source: 'file://{{ etcd.tmpdir }}/{{ etcd.dl.archive_name }}'
    - name: '{{ etcd.prefix }}'
    - archive_format: {{ etcd.dl.format.split('.')[0] }}
    - unless: test -f {{ etcd.realhome }}{{ etcd.command }}
    - watch_in:
      - service: etcd_{{ etcd.service_name }}_running
    - onchanges:
      - cmd: etcd-download-archive
    {%- if etcd.src_hashurl and grains['saltversioninfo'] > [2016, 11, 6] %}
    - source_hash: {{ etcd.src_hashurl }}
    {% endif %}

etcd-link:
  file.symlink:
    - target: {{ etcd.realhome }}/etcd
    - name: /usr/local/bin/etcd
    - watch:
      - archive: etcd-install

etcd-etcdctl-link:
  file.symlink:
    - target: {{ etcd.realhome }}/etcdctl
    - name: /usr/local/bin/etcdctl
    - watch:
      - archive: etcd-install

