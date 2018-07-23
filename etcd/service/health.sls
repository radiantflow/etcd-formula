# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "etcd/map.jinja" import etcd with context %}

show etcd cluster health:
  cmd.run:
    - name: ./etcdctl cluster-health
    - cwd: {{ opensds.realhome }}

