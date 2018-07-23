# -*- coding: utf-8 -*-
# vim: ft=yaml
{% from "etcd/map.jinja" import etcd with context -%}

   {% if etcd.docker.stop_etcd_service_first %}
include:
  - etcd.service.stopped
   {% endif %}

{% for pkg in etcd.docker.packages -%}
  {% if pkg %}
etcd-docker-{{ pkg }}-package:
  pkg.installed:
    - name:  {{ pkg }}
    - require_in:
      - docker_container: run-etcd-dockerized-service
    - onfail_in:
      - pip: etcd-docker-python-module
  {% endif %}
{% endfor %}

etcd-docker-python-module:
  pip.installed:
    - name: 'docker'
    - reload_modules: True
    - exists_action: i
    - force_reinstall: True
    - require_in:
      - docker_container: run-etcd-dockerized-service

etcd-ensure-docker-service:
  service.running:
    - name: docker
    - require_in:
      - docker_container: run-etcd-dockerized-service

run-etcd-dockerized-service:
  docker_container.running:
       {% if etcd.docker.version %}
    - image: {{ etcd.docker.image }}:{{ etcd.docker.version }}
       {% else %}
    - image: {{ etcd.docker.image }}
       {% endif %}
    - command: {{ etcd.docker.cmd }}
    - binds:
        {% for volume in etcd.docker.volumes %}
      - {{ volume }}
        {% endfor %}
    - port_bindings:
        {% for port in etcd.docker.ports %}
      - {{ port }}
        {% endfor %}
