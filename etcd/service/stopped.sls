# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "etcd/map.jinja" import etcd with context %}

etcd_{{ etcd.service_name }}_stopped:
  service.dead:
    - name: {{ etcd.service_name }}

