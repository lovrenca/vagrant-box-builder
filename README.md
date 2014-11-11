Kendu-box autobuild
===================

This script takes an exported minimal install ubuntu virtualbox appliance,
sets it up, shrinks, packages and exports to the web directory where you share the box.

There should be an exported virtual machine where:
-----------------------------------------------------------------------------

- the default user is vagrant

- the password is vagrant

- that passwordless sudo is set for the default user

- that there is a ssh keypair in the keys directory named id_rsa

- that the public key is aded to the default users authorized_keys

Any changes to the box are defined in the setup.sh script, modify acording to your wishes.
If you wish for some extra security, generating new kex files is advised.
In the autobuild script change the name of the box you're building
and the path to the web root where you share the box and run :)