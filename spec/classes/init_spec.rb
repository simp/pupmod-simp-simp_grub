require 'spec_helper'

describe 'simp_grub' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) do
          os_facts
        end

        let(:uniqueid) { '0875ff34' }
        context 'with useful parameters' do
          let(:params){{
            :password => 'useful parameters',
            :admin    => 'root'
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('simp_grub') }

          if os_facts[:augeasprovider_grub_version] == 1
            it { is_expected.to create_exec('Set Grub Password') }
          else
            it {
              is_expected.to create_grub_user(params[:admin]).with({
                :password  => params[:password],
                :superuser => true
              })
            }
          end
        end

        context 'with all parameters' do
          let(:params){{
            :password               => 'all parameters',
            :admin                  => 'root',
            :purge_unmanaged_users  => true,
            :report_unmanaged_users => true,
            :hash_rounds            => 10000
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('simp_grub') }

          if os_facts[:augeasprovider_grub_version] == 1
            it { is_expected.to create_exec('Set Grub Password') }
          else
            it {
              is_expected.to create_grub_user(params[:admin]).with({
                :password         => params[:password],
                :superuser        => true,
                :report_unmanaged => params[:report_unmanaged_users],
                :purge            => params[:purge_unmanaged_users],
                :rounds           => params[:hash_rounds]
              })
            }
          end
        end

        if os_facts[:augeasprovider_grub_version] == 1
          context 'with GRUB 0.99' do
            let(:params){{
              :password => test_pass
            }}

            context 'with MD5 password' do
              let(:test_pass) {
                require 'digest'

                '$1$' + "#{:uniqueid}" + '$' +
                  Digest::MD5.hexdigest('my password' + "#{:uniqueid}")
              }

              it { is_expected.to create_exec('Set Grub Password').with_unless("grep -qx 'password --encrypted #{test_pass}' /etc/grub.conf") }
            end

            context 'with SHA256 password' do
              let(:test_pass) {
                require 'digest'

                '$5$' + "#{:uniqueid}" + '$' +
                  Digest::SHA2.new(256).hexdigest('my password' + "#{:uniqueid}")
              }

              it { is_expected.to create_exec('Set Grub Password').with_unless("grep -qx 'password --encrypted #{test_pass}' /etc/grub.conf") }
            end

            context 'with SHA512 password' do
              let(:test_pass) {
                require 'digest'

                '$5$' + "#{:uniqueid}" + '$' +
                  Digest::SHA2.new(512).hexdigest('my password' + "#{:uniqueid}")
              }

              it { is_expected.to create_exec('Set Grub Password').with_unless("grep -qx 'password --encrypted #{test_pass}' /etc/grub.conf" ) }
            end
          end
        else
          context 'with GRUB 2' do
            let(:params){{
              :password => 'grub two'
            }}

            it {
              expect {
                is_expected.to(compile.with_all_deps)
              }.to raise_error(/You must pass "\$admin/)
            }
          end
        end
      end
    end
  end
end
