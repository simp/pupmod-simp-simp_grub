# frozen_string_literal: true

Facter.add(:simp_grub__grub2_installed) do
  confine kernel: :linux
  setcode do
    File.directory?('/etc/grub.d') &&
      !(Facter::Core::Execution.which('grub2-mkconfig') || Facter::Core::Execution.which('grub-mkconfig')).nil?
  end
end
