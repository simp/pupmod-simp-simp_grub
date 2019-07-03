[![License](https://img.shields.io/:license-apache-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/simp_grub.svg)](https://forge.puppetlabs.com/simp/simp_grub)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/simp_grub.svg)](https://forge.puppetlabs.com/simp/simp_grub)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-simp_grub.svg)](https://travis-ci.org/simp/pupmod-simp-simp_grub)

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [Overview](#overview)
* [This is a SIMP module](#this-is-a-simp-module)
* [Module Description](#module-description)
* [Setup](#setup)
  * [What simp_grub affects](#what-simp_grub-affects)
* [Usage](#usage)
  * [GRUB2](#grub2)
* [Limitations](#limitations)
* [Development](#development)
  * [Unit tests](#unit-tests)
  * [Acceptance tests](#acceptance-tests)

<!-- vim-markdown-toc -->

## Overview

## This is a SIMP module

This module is a component of the [System Integrity Management Platform](https://simp-project.com)

If you find any issues, please submit them via [JIRA](https://simp-project.atlassian.net/).

Please read our [Contribution Guide] (https://simp.readthedocs.io/en/stable/contributors_guide/index.html).

## Module Description

Provides a Hiera-friendly interface to GRUB configuration activities.

Currently supports setting administrative GRUB passwords on both GRUB 2 and
legacy GRUB systems.

See [REFERENCE.md](REFERENCE.md) for more details.

## Setup

### What simp_grub affects

`simp_grub` helps manage the GRUB configuration on your systems.

## Usage

Simply ``include simp_grub`` and set the ``simp_grub::password`` parameter to
password protect GRUB.

Password entries that do not start with `$1$`, `$5$`, or `$6$` will be encrypted
for you.

### GRUB2

If your system supports GRUB2, you can also set up the administrative username.

Example: Set the admin username:

```yaml
---
simp_grub::admin: my_admin_username
```

## Limitations

SIMP Puppet modules are generally intended to be used on a Red Hat Enterprise
Linux-compatible distribution such as EL6 and EL7.

## Development

Please read our [Contribution Guide] (https://simp.readthedocs.io/en/stable/contributors_guide/index.html).

### Unit tests

Unit tests, written in ``rspec-puppet`` can be run by calling:

```shell
bundle exec rake spec
```

### Acceptance tests

To run the system tests, you need [Vagrant](https://www.vagrantup.com/) installed. Then, run:

```shell
bundle exec rake beaker:suites
```

Some environment variables may be useful:

```shell
BEAKER_debug=true
BEAKER_provision=no
BEAKER_destroy=no
BEAKER_use_fixtures_dir_for_modules=yes
```

* `BEAKER_debug`: show the commands being run on the STU and their output.
* `BEAKER_destroy=no`: prevent the machine destruction after the tests finish so you can inspect the state.
* `BEAKER_provision=no`: prevent the machine from being recreated. This can save a lot of time while you're writing the tests.
* `BEAKER_use_fixtures_dir_for_modules=yes`: cause all module dependencies to be loaded from the `spec/fixtures/modules` directory, based on the contents of `.fixtures.yml`.  The contents of this directory are usually populated by `bundle exec rake spec_prep`.  This can be used to run acceptance tests to run on isolated networks.
