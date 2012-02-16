/*
== Definition: postfix::config

Uses the "postconf" command to add/alter/remove options in postfix main
configuation file (/etc/postfix/main.cf).

Parameters:
- *name*: name of the parameter.
- *ensure*: present/absent. defaults to present.
- *value*: value of the parameter.

Requires:
- Class["postfix"]

Example usage:

  node "toto.example.com" {

    include postfix

    postfix::config {
      "smtp_use_tls"            => "yes";
      "smtp_sasl_auth_enable"   => "yes";
      "smtp_sasl_password_maps" => "hash:/etc/postfix/my_sasl_passwords";
      "relayhost"               => "[mail.example.com]:587";
    }
  }

*/
define postfix::config ($ensure = present, $multi = false, $instance_group = "mta", $value) {

  case $ensure {
    present: {
      if $multi {
        # ATTN!
        # We assume the whole group has the same config. Otherwise either unless
        # block becomes bloated or we have to run postconf EACH TIME we have puppet
        # executing it's stuff
        exec { "postmulti -g ${instance_group} -x postconf -e ${name}='${value}'":
          unless => "test \"x$(postmulti -g ${instance_group} -x postconf -h ${name}) | head -n 1\" = 'x${value}'"
        }
      } else {
          exec { "postconf -e ${name}='${value}'":
            unless => "test \"x$(postconf -h ${name})\" = 'x${value}'"
          }
        }
    }

    absent: {
      fail "postfix::config ensure => absent: Not implemented"
    }
  }
}
#vim: set ts=2 sw=2 cin et
