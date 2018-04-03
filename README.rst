etcd
====

Formula to install and configure etcd.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.
    Refer to pillar.example and defaults.yaml for configurable values. Tested on Linux (Ubuntu), MacOS planned. Not verified on Windows OS.
    
Available states
================

.. contents::
    :local:

``etcd``
------------
Metastate for all deployment states.


``etcd.install``
------------
Installs etcd version by downloading the archive from github and extracting it to the {{ etcd.lookup.prefix }} directory.

``etcd.service``
------------
Configure and (re)start your ETCD service and clusters.

``etcd.linuxenv``
------------
Configure launchd, systemd, or upstart configuration, this will copy. Setup linux alternatives if enabled and supported.

.. note::

Enable linux alternatives by setting nonzero 'altpriority' pillar value; otherwise feature is disabled.

