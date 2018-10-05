# -*- coding: utf-8 -*-
# vim: ft=yaml
{% from "etcd/map.jinja" import etcd with context -%}

include:
  - etcd.install
  - etcd.service

extend:
  etcd_{{ etcd.service_name }}_running:
    service:
      - listen:
        - archive: etcd-install
      - require:
        - archive: etcd-install