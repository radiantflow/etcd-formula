# -*- coding: utf-8 -*-
# vim: ft=yaml
{% from "etcd/map.jinja" import etcd with context -%}

include:
  - etcd.install
  - etcd.service
  - etcd.linuxenv

extend:
  etcd_{{ etcd.service }}_running:
    service:
      - listen:
           {% if etcd.use_upstream_repo|lower == 'homebrew' %}
        - file: etcd-install
           {% else %}
        - archive: etcd-install
           {% endif %}
      - require:
           {% if etcd.use_upstream_repo|lower == 'homebrew' %}
        - file: etcd-install
           {% else %}
        - archive: etcd-install
           {% endif %}

