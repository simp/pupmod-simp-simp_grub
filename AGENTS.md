# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

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
bundle exec rake spec                                                      # Run all unit tests
bundle exec rspec spec/classes/init_spec.rb                                # Run a single class spec
bundle exec rspec spec/unit/facter/simp_grub__grub2_installed_spec.rb     # Run the facter spec
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

Both `$password` and `$admin` are **required** parameters with no defaults — they must be supplied via Hiera or the class declaration. The class is a no-op on systems where GRUB 2 is not installed (e.g. Docker containers), controlled by the `simp_grub__grub2_installed` fact.

### GRUB 2 installation detection

`lib/facter/simp_grub__grub2_installed.rb` defines the custom fact `simp_grub__grub2_installed`. It returns `true` only when both `/etc/grub.d` exists **and** `grub2-mkconfig` or `grub-mkconfig` is on PATH — mirroring the confine conditions on the `grub_user` provider. When the fact is false or absent (containers, non-Linux), the class skips the `grub_user` resource entirely to avoid a "no suitable provider" error.

### grub_user resource

When `simp_grub__grub2_installed` is true, the class declares a single `grub_user` resource from `puppet/augeasproviders_grub`. Password handling is done entirely by the native type: plaintext passwords are auto-hashed using PBKDF2; passwords already in PBKDF2 format (`grub.pbkdf2.sha512.*`) are passed through unchanged.

### Key dependencies

- `puppet/augeasproviders_grub` (>= 6.0.0) — provides the `grub_user` native type; GRUB 1 is not supported
- `simp/simplib` — provides `simplib::assert_metadata`
- `puppetlabs/stdlib` — declared dependency (available if needed)

### Unit test structure

- `spec/classes/init_spec.rb` — class tests; uses `rspec-puppet` with `simp-rspec-puppet-facts` to iterate over all OS/version combinations from `metadata.json`. Facts include `simp_grub__grub2_installed: true` by default; a separate context covers the `false` case.
- `spec/unit/facter/simp_grub__grub2_installed_spec.rb` — facter spec; stubs `File.directory?` and `Facter::Core::Execution.which` to test all code paths; includes a non-Linux confine test.

Fixtures are cloned per `.fixtures.yml` and installed to `spec/fixtures/modules/` by `rake spec_prep`.

Hieradata for tests can be loaded by creating YAML files under `spec/fixtures/hieradata/` and calling `set_hieradata('filename')` in the spec (colons in class names become underscores in filenames).

### Files maintained by puppetsync

`Gemfile` and `spec/spec_helper.rb` are managed by the upstream `puppetsync` baseline and will be overwritten on the next sync. Avoid making local changes to these files.
