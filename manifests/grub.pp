# == Class: docker::grub
#
# For systems that need grub modififications
class docker::grub {
  file_line { 'memory_cgroup':
    path => '/etc/default/grub',
    line => 'GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} cgroup_enable=memory"'
  } ~>
  exec { 'rebuild-grub':
    path        => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    command     => 'update-grub2',
    refreshonly => true,
  }
}
