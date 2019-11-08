All ssh public keys within this folder will be added to the authorized_keys
file (/home/pi/.ssh/authorized_keys) of the pi user of the generated target
system (container or OS image).

This will then allow the corresponding people to have a convenient access
to the target system using ssh (e.g. ssh pi@IP_OF_TARGET_SYSTEM).

This is especially useful within a company setup where one employee (or a build
server) generates the images and multiple other employees want to access the
systems that are running those images in a secure way without sharing a static
password.

This folder of course will remain empty within this repository but you can do
your private fork and add public keys there.

The extension of the public key files must be .pub.

Examples:
coworker1_id_rsa.pub
coworker2_id_rsa.pub
ben.pub
karl_id_rsa.pub

For your convenience there is also a second mechanism in place that adds the public
key of the user that generates the artifacts. This is part of the "base_system" Ansible
playbook plugin (you can use "authorize_current_user: False" to turn this feature off).
For more details please take a look at this documentation:
https://docs.get-edi.io/en/latest/config_management/plugins.html

For even more information please read this blog post:
https://www.get-edi.io/Secure-by-Default-ssh-Setup/

Please note that password based login via ssh is disabled by default within the
edi-pi configuration.
