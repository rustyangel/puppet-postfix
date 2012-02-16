#
# == Class: postfix
#
# This class provides a basic setup of postfix with local and remote
# delivery and an SMTP server listening on the loopback interface.
#
# Parameters:
# - *$postfix_smtp_listen*: address on which the smtp service will listen to. defaults to 127.0.0.1
# - *$root_mail_recipient*: who will recieve root's emails. defaults to "nobody"
#
# Example usage:
#
#   node "toto.example.com" {
#     $postfix_smtp_listen = "192.168.1.10"
#     include postfix
#   }
#
class postfix {

  # Default value for various options
  case $root_mail_recipient {
    "":   { $root_mail_recipient = "nobody" }
  }

  package { "postfix":
    ensure => installed
  }

  package { "mailx":
    ensure => installed,
    name   => "mailx",
    }

  service { "postfix":
    ensure    => running,
    enable    => true,
    hasstatus => true,
    restart   => "/etc/init.d/postfix reload",
    require   => Package["postfix"],
  }

  # Aliases
  file { "/etc/aliases":
    ensure => present,
    content => "# file managed by puppet\n",
    replace => false,
    notify => Exec["newaliases"],
  }

  # Aliases
  exec { "newaliases":
    command     => "/usr/bin/newaliases",
    refreshonly => true,
    require     => Package["postfix"],
    subscribe   => File["/etc/aliases"],
  }

  # Config files
  file { "/etc/postfix/master.cf":
    ensure  => present,
    owner => "root",
    group => "root",
    mode => "0644",
    source => "puppet:///modules/postfix/master.cf",
    notify  => Service["postfix"],
    require => Package["postfix"],
  }

  # Config files
  file { "/etc/postfix/main.cf":
    ensure  => present,
    owner => "root",
    group => "root",
    mode => "0644",
    source  => "puppet:///modules/postfix/main.cf",
    replace => false,
    notify  => Service["postfix"],
    require => Package["postfix"],
  }

  # Default configuration parameters
  postfix::config {
    "myorigin":   value => "${fqdn}";
    "alias_maps": value => "hash:/etc/aliases";
    "inet_interfaces": value => "127.0.0.1";
  }

	postfix::config {
		"sendmail_path": value => "/usr/sbin/sendmail";
		"newaliases_path": value => "/usr/bin/newaliases";
		"mailq_path": value => "/usr/bin/mailq";
	}

  mailalias {"root":
    recipient => $root_mail_recipient,
    notify    => Exec["newaliases"],
  }
}
# vim: set ts=2 sw=2 cin et
