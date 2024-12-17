require 'beaker-rspec'
require 'tmpdir'
require 'yaml'
require 'simp/beaker_helpers'
include Simp::BeakerHelpers

unless ENV['BEAKER_provision'] == 'no'
  hosts.each do |host|
    # Install Puppet
    if host.is_pe?
      install_pe
    else
      install_puppet
    end
  end
end

parallel = { run_in_parallel: ['yes', 'true', 'on'].include?(ENV['BEAKER_SIMP_parallel']) }

RSpec.configure do |c|
  # ensure that environment OS is ready on each host
  fix_errata_on hosts

  # Detect cases in which no examples are executed (e.g., nodeset does not
  # have hosts with required roles)
  c.fail_if_no_examples = true

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install modules and dependencies from spec/fixtures/modules
    copy_fixture_modules_to(hosts)

    # Make sure that the SIMP default environment files are in place if they
    # exist
    block_on(hosts, parallel) do |sut|
      environment = on(sut, 'puppet config print environment').output.strip

      tgt_path = '/var/simp/environments'

      found = false
      on(sut, %(puppet config print modulepath --environment #{environment})).output.strip.split(':').each do |mod_path|
        next unless on(sut, "ls #{mod_path}/simp_environment 2>/dev/null ", accept_all_exit_codes: true).exit_code == 0

        unless found
          on(sut, %(mkdir -p #{tgt_path}))
        end

        found = true

        on(sut, %(cp -r #{mod_path}/simp_environment #{tgt_path}))
        on(sut, %(rm -rf #{mod_path}/simp_environment))
      end

      if found
        on(sut, %(mv #{tgt_path}/simp_environment #{tgt_path}/#{environment}))
      end
    end

    # Generate and install PKI certificates on each SUT
    Dir.mktmpdir do |cert_dir|
      run_fake_pki_ca_on(default, hosts, cert_dir)
      hosts.each { |sut| copy_pki_to(sut, cert_dir, '/etc/pki/simp-testing') }
    end

    # add PKI keys
    copy_keydist_to(default)
  rescue StandardError, ScriptError => e
    raise e unless ENV['PRY']
    require 'pry'
    binding.pry # rubocop:disable Lint/Debugger
  end
end
