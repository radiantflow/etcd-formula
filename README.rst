etcd
====

Formula to install and configure etcd on Linux and MacOS.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.
    Refer to pillar.example and defaults.yaml for configurable values.
    
Available states
================

.. contents::
    :local:

``etcd``
------------
Metastate for all the software and service deployment states.

``etcd.install``
------------
Installs etcd version by downloading the archive from github and extracting it to the {{ etcd.prefix }} directory.

``etcd.linuxenv``
------------
Configure launchd, systemd, or upstart configuration, this will copy. Setup linux alternatives if enabled and supported.

.. note:: Enable linux alternatives by setting nonzero 'altpriority' pillar value; otherwise feature is disabled.

``etcd.service``
------------
Ensure the `etcd` service is registered and (re)started on minion.

``etcd.service.stopped``
------------
Ensure the `etcd` service is stopped on minion.

``etcd.docker.running``
------------
Ensure that an `etcd` container with a specific configuration is present and running. Requires Docker to be running - you could run ``docker`` state from ``docker-formula`` to ensure this requirement.

State top file::

        base:
          '*':
            - docker                  #saltstack-formulas/docker-formula
            - etcd.docker.running     #saltstack-formulas/etcd-formula


``etcd.docker.stopped``
------------
Ensure that `etcd` container is stopped
