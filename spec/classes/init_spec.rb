require 'spec_helper'

describe 'simp_grub' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) do
          os_facts.merge({ simp_grub__grub2_installed: true })
        end

        context 'with useful parameters' do
          let(:params) do
            {
              password: 'useful parameters',
              admin: 'root',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('simp_grub') }
          it {
            is_expected.to create_grub_user(params[:admin]).with(
              password: params[:password],
              superuser: true,
            )
          }
        end

        context 'with all parameters' do
          let(:params) do
            {
              password: 'all parameters',
              admin: 'root',
              purge_unmanaged_users: true,
              report_unmanaged_users: true,
              hash_rounds: 10_000,
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('simp_grub') }
          it {
            is_expected.to create_grub_user(params[:admin]).with(
              password: params[:password],
              superuser: true,
              report_unmanaged: params[:report_unmanaged_users],
              purge: params[:purge_unmanaged_users],
              rounds: params[:hash_rounds],
            )
          }
        end

        context 'without admin parameter' do
          let(:params) do
            {
              password: 'grub two',
            }
          end

          it {
            expect {
              is_expected.to(compile.with_all_deps)
            }.to raise_error(%r{expects a value for parameter 'admin'})
          }
        end

        context 'when grub2 is not installed' do
          let(:facts) do
            os_facts.merge({ simp_grub__grub2_installed: false })
          end

          let(:params) do
            {
              password: 'some password',
              admin: 'root',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.not_to contain_grub_user('root') }
        end
      end
    end
  end
end
