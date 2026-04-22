# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is `pupmod-simp-simp_grub`, a Puppet module that provides a Hiera-friendly interface for managing GRUB 2 configuration — specifically, setting administrative passwords. It targets RHEL-compatible distributions (CentOS, RHEL, OracleLinux, Rocky, AlmaLinux) versions 8–10.

## Commands

### Setup

```shell
bundle install
bundle exec rake spec_prep   # Install fixture modules from .fixtures.yml
```

### Testing

```shell
bundle exec rake spec                          # Run all unit tests
bundle exec rspec spec/classes/init_spec.rb    # Run a single spec file
```

### Linting & Syntax

```shell
bundle exec rake lint          # puppet-lint checks
bundle exec rake syntax        # Puppet manifest syntax validation
bundle exec rake metadata_lint # Validate metadata.json
bundle exec rake rubocop       # Ruby style checks
bundle exec rake validate      # All syntax/lint checks combined
```

### Acceptance Tests

Vagrant-based:
```shell
bundle exec rake beaker:suites
```

Docker-based nodesets (e.g. `docker_rhel9`, `docker_alma8`) are available in `spec/acceptance/nodesets/` and can be selected with `BEAKER_set`:
```shell
BEAKER_set=docker_rhel9 bundle exec rake beaker:suites
```

Useful env vars for acceptance tests:
- `BEAKER_debug=true` — show commands and output on SUTs
- `BEAKER_provision=no` — skip machine recreation
- `BEAKER_destroy=no` — keep machine after tests
- `BEAKER_use_fixtures_dir_for_modules=yes` — use `spec/fixtures/modules` for dependencies

### Documentation

```shell
bundle exec rake strings:generate   # Generate REFERENCE.md from Puppet Strings
```

## Architecture

This module has a single entry point: `manifests/init.pp` (`class simp_grub`).

The class delegates directly to the `grub_user` native type from `augeasproviders_grub`. Both `$password` and `$admin` are required parameters with no defaults — they must be supplied via Hiera or the class declaration.

Password handling is done by the native type: plaintext passwords are auto-hashed using PBKDF2; passwords already in PBKDF2 format are passed through unchanged.

### Key dependencies

- `puppet/augeasproviders_grub` — provides the `grub_user` native type
- `simp/simplib` — provides `simplib::assert_metadata`
- `puppetlabs/stdlib` — declared dependency (available if needed)

### Unit test structure

Tests live in `spec/classes/init_spec.rb` and use `rspec-puppet` with `simp-rspec-puppet-facts` to iterate over all supported OS/version combinations from `metadata.json`. Fixtures are cloned per `.fixtures.yml` and installed to `spec/fixtures/modules/` by `rake spec_prep`.

Hieradata for tests can be loaded by creating YAML files under `spec/fixtures/hieradata/` and calling `set_hieradata('filename')` in the spec (colons in class names become underscores in filenames).

### Files maintained by puppetsync

`Gemfile` and `spec/spec_helper.rb` are managed by the upstream `puppetsync` baseline and will be overwritten on the next sync. Avoid making local changes to these files.
