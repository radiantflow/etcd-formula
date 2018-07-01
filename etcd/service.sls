# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "etcd/map.jinja" import etcd with context %}

{% if grains.os == 'MacOS' and etcd.lookup.use_upstream_repo|lower == 'homebrew' %}

etcd-launchd:
  file.managed:
    - name: /Library/LaunchAgents/{{ etcd.lookup.service_name }}.plist
    - source: /usr/local/opt/etcd/{{ etcd.lookup.service_name }}.plist
    - group: wheel
    - watch_in:
      - etcd_{{ etcd.lookup.service_name }}_running

{% elif grains.init == 'systemd' %}

etcd-systemd:
  file.managed:
    - name: '/etc/systemd/system/{{ etcd.lookup.service_name }}.service'
    - source: 'salt://etcd/files/systemd.service.jinja'
    - user: root
    - group: root
    - mode: '0750'
    - template: jinja
    - context:
      etcd: {{ etcd|json }}
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: etcd-systemd
    - require:
      - file: etcd-systemd
    - require_in:
      - service:  etcd_{{ etcd.lookup.service_name }}_running

{% elif grains.init  == 'upstart' %}

etcd-service:
  file.managed:
    - name: '/etc/init/{{ etcd.lookup.service_name }}.conf'
    - source: 'salt://etcd/files/upstart.service.jinja'
    - user: root
    - group: root
    - mode: '0750'
    - template: jinja
    - context:
      etcd: {{ etcd|json }}
    - require_in:
      - service:  etcd_{{ etcd.lookup.service_name }}_running

{% endif %}

etcd_{{ etcd.lookup.service_name }}_running:
  service.running:
    - name: {{ etcd.lookup.service_name }}
    - enable: {{ etcd.lookup.service_enabled }}
    # todo: add launchd service for non-homebrew installs on MacOS
    - unless: test "`uname`" = "Darwin" && "{{ etcd.lookup.use_upstream_repo|lower }}" ==  "true"

