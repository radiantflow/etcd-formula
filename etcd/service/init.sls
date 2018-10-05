# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "etcd/map.jinja" import etcd with context %}


{% if grains.init == 'systemd' %}

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
    - defaults:
{%- if salt['cmd.shell']('. /var/lib/etcd/configenv; etcdctl cluster-health > /dev/null 2>&1; echo $?') != '0' %}
        initial_cluster_state: new
{%- else %}
        initial_cluster_state: existing
{%- endif %}
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

