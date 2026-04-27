require 'spec_helper_acceptance'
require 'json'

test_name 'simp_grub'

describe 'simp_grub class' do
  let(:manifest) do
    <<~EOS
      include 'simp_grub'
    EOS
  end

  hosts.each do |host|
    context "on #{host}" do
      simp_grub__grub2_installed = on(host, 'test -d /etc/grub.d && (command -v grub2-mkconfig || command -v grub-mkconfig)', accept_all_exit_codes: true).exit_code == 0

      let(:hieradata) do
        {
          'simp_grub::password' => 'test password',
          'simp_grub::admin'    => 'admin',
        }
      end

      it 'applies manifest' do
        set_hieradata_on(host, hieradata)
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end

      if simp_grub__grub2_installed
        let(:grub_cfg) { on(host, 'cat /etc/grub2.cfg').output.lines }
        let(:password_entries) do
          passwords = grub_cfg.grep(%r{password_pbkdf2})

          # Remove comments
          passwords.delete_if { |x| x =~ %r{^\s*#} }
          # Remove the regular 'root' entry
          passwords.delete_if { |x| x.include?(' root ') }

          passwords.map(&:strip)
        end

        it 'has a superuser named "admin"' do
          superusers = grub_cfg.grep(%r{set\s+superusers})

          # Remove comments
          superusers.delete_if { |x| x =~ %r{^\s*#} }
          # Remove the regular 'root' entry
          superusers.delete_if { |x| x.include?('"root"') }

          superusers.map!(&:strip)

          expect(superusers).to eq(['set superusers="admin"'])
        end

        it 'has a password in place for "admin"' do
          expect(password_entries.count).to eq(1)
          expect(password_entries.first).to match(%r{^password_pbkdf2 admin grub\.pbkdf2.+})
        end

        context 'with pregenerated password hash' do
          # rubocop:disable Layout/LineLength
          let(:pw_hash) do
            'grub.pbkdf2.sha512.10000.A6450DF58428B9AFDC4CED89BE2B94C74ACB153FD01BEDE4F6AEDA661854E987B1B00675533E270FFCC71FAE914789D06071704CAB9BCBB539F95C0D6952EB78.83D980313DBAE4DFE9F66EA23F91425416B4D4C816C42B6ACC0D46BBA25750203D056D5C7F103BC1A350F24F0C4AA8850961D18FD9132640723A3810BB741E4F'
          end
          # rubocop:enable Layout/LineLength

          let(:hieradata) do
            {
              'simp_grub::password' => pw_hash,
              'simp_grub::admin'    => 'admin',
            }
          end

          it 'applies manifest' do
            set_hieradata_on(host, hieradata)
            apply_manifest_on(host, manifest, catch_failures: true)
          end

          it 'has the known password in place' do
            expect(password_entries.count).to eq(1)
            expect(password_entries.first).to match(%r{^password_pbkdf2 admin #{Regexp.escape(pw_hash)}$})
          end
        end
      end
    end
  end
end
