# frozen_string_literal: true

require 'spec_helper'
require 'facter'
require 'facter/simp_grub__grub2_installed'

describe :simp_grub__grub2_installed, type: :fact do
  subject(:fact) { Facter.fact(:simp_grub__grub2_installed) }

  on_supported_os.each do |os, os_facts|
    before :each do
      Facter.clear
    end

    context "on #{os}" do
      let(:facts) { os_facts }

      before :each do
        allow(Facter.fact(:kernel)).to receive(:value).and_return(facts[:kernel])
      end

      context 'with /etc/grub.d present and grub2-mkconfig available' do
        before :each do
          allow(File).to receive(:directory?).and_call_original
          allow(File).to receive(:directory?).with('/etc/grub.d').and_return(true)
          allow(Facter::Core::Execution).to receive(:which).with('grub2-mkconfig').and_return('/usr/sbin/grub2-mkconfig')
          allow(Facter::Core::Execution).to receive(:which).with('grub-mkconfig').and_return(nil)
        end

        it { expect(fact.value).to be(true) }
      end

      context 'with /etc/grub.d present and only grub-mkconfig available' do
        before :each do
          allow(File).to receive(:directory?).and_call_original
          allow(File).to receive(:directory?).with('/etc/grub.d').and_return(true)
          allow(Facter::Core::Execution).to receive(:which).with('grub2-mkconfig').and_return(nil)
          allow(Facter::Core::Execution).to receive(:which).with('grub-mkconfig').and_return('/usr/sbin/grub-mkconfig')
        end

        it { expect(fact.value).to be(true) }
      end

      context 'with /etc/grub.d present but no mkconfig binary available' do
        before :each do
          allow(File).to receive(:directory?).and_call_original
          allow(File).to receive(:directory?).with('/etc/grub.d').and_return(true)
          allow(Facter::Core::Execution).to receive(:which).with('grub2-mkconfig').and_return(nil)
          allow(Facter::Core::Execution).to receive(:which).with('grub-mkconfig').and_return(nil)
        end

        it { expect(fact.value).to be(false) }
      end

      context 'with /etc/grub.d absent' do
        before :each do
          allow(File).to receive(:directory?).and_call_original
          allow(File).to receive(:directory?).with('/etc/grub.d').and_return(false)
        end

        it { expect(fact.value).to be(false) }
      end
    end
  end

  context 'on a non-Linux host' do
    before :each do
      Facter.clear
      allow(Facter.fact(:kernel)).to receive(:value).and_return('windows')
    end

    it 'returns nil' do
      expect(fact.value).to be_nil
    end
  end
end
