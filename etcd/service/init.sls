# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "etcd/map.jinja" import etcd with context %}


{% if grains.init == 'systemd' %}

{% if etcd.service.initial_cluster_state == 'existing' and salt['grains.get']('etcd_initialized') != True  %}
etcd-initialized:
  cmd.script:
    - source: salt://etcd/files/add_member.jinja
    - shell: /bin/bash
    - template: jinja
    - context:
      etcd: {{ etcd|json }}
  grains.present:
    - name: etcd_initialized
    - value: True
{% endif %}

etcd-default:
  file.managed:
    - name: /etc/default/etcd
    - source: salt://etcd/files/default.jinja
    - user: root
    - group: root
    - mode: '0644'
    - template: jinja
    - context:
      etcd: {{ etcd|json }}
    - watch_in:
      - etcd_{{ etcd.service_name }}_running

etcd-systemd:
  file.managed:
    - name: '/etc/systemd/system/{{ etcd.service_name }}.service'
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
      - service:  etcd_{{ etcd.service_name }}_running

{% endif %}

etcd_{{ etcd.service_name }}_running:
  service.running:
    - name: {{ etcd.service_name }}
    - enable: {{ etcd.service_enabled }}
    - watch:
      - file: etcd-default

etcd_whats_wrong_with_{{ etcd.service_name }}:
  cmd.run:
    - names:
      - journalctl -xe -u etcd
      - service status etcd
    - onfail:
      - service: etcd_{{ etcd.service_name }}_running

