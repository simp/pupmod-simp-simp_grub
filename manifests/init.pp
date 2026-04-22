# @summary Manage common GRUB attributes
#
# Advanced configuration will need to use the `augeasproviders_grub` components
# directly.
#
# @param password
#   The GRUB administrative password, if not in the hashed form, will be
#   converted for you.
#
#   * If a password is in PBKDF2 form, then it is assumed to be encrypted.
#
# @param admin
#   The administrative username for GRUB 2.
#
# @param purge_unmanaged_users
#   Remove users from GRUB 2 systems that are not managed by Puppet.
#
# @param report_unmanaged_users
#   Report on any unmanaged users on GRUB 2 systems.
#
# @param hash_rounds
#   The rounds to use when hashing the password for GRUB 2 systems.
#
# @author https://github.com/simp/pupmod-simp-simp/contributors
class simp_grub (
  String[1]             $password,
  String[1]             $admin,
  Optional[Boolean]     $purge_unmanaged_users  = undef,
  Optional[Boolean]     $report_unmanaged_users = undef,
  Optional[Integer[10]] $hash_rounds            = undef
) {
  simplib::assert_metadata($module_name)

  if $facts['simp_grub__grub2_installed'] {
    grub_user { $admin:
      password         => $password,
      superuser        => true,
      report_unmanaged => $report_unmanaged_users,
      purge            => $purge_unmanaged_users,
      rounds           => $hash_rounds,
    }
  }
}
