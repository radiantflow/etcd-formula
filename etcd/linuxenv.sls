{% from "etcd/map.jinja" import etcd with context %}

{% if grains.os not in ('Windows',) %}

etcd-home-symlink:
  file.symlink:
    - name: '{{ etcd.symhome }}'
    - target: '{{ etcd.realhome }}'
    - onlyif: test -d {{ etcd.realhome }}
    - force: True

# Update system profile with PATH
etcd-config:
  file.managed:
    - name: /etc/profile.d/etcd.sh
    - source: salt://etcd/files/etcd.sh
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - unless: test "`uname`" = "Darwin"
    - context:
      etcd: {{ etcd|json }}

  # Alternatives system
  {% if etcd.linux.altpriority > 0 and grains.os_family not in ('MacOS', 'Arch',) %}

# Add etcd-home to alternatives system
etcd-home-alt-install:
  alternatives.install:
    - name: etcd-home
    - link: '{{ etcd.symhome }}'
    - path: '{{ etcd.realhome }}'
    - priority: {{ etcd.linux.altpriority }}

etcd-home-alt-set:
  alternatives.set:
    - name: etcd-home
    - path: {{ etcd.realhome }}
    - onchanges:
      - alternatives: etcd-home-alt-install

# Add etcd to alternatives system
etcd-alt-install:
  alternatives.install:
    - name: etcd
    - link: {{ etcd.linux.symlink }}
    - path: {{ etcd.realhome }}/etcd
    - priority: {{ etcd.linux.altpriority }}
    - require:
      - alternatives: etcd-home-alt-install
      - alternatives: etcd-home-alt-set

etcd-alt-set:
  alternatives.set:
    - name: etcd
    - path: {{ etcd.realhome }}/etcd
    - onchanges:
      - alternatives: etcd-alt-install

  {% endif %}

{% endif %}
