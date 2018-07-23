# -*- coding: utf-8 -*-
# vim: ft=yaml
{% from "etcd/map.jinja" import etcd with context -%}

etcd-check-docker-service-running:
  service.running:
    - name: docker
    - require_in:
      - docker_container: stop etcd dockerized service

stop etcd dockerized service:
  docker_container.stopped:
    - name: run-etcd-dockerized-service
