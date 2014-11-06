Kendu-box autobuild
===================
There should be an exported vmware machine where:
-----------------------------------------------------------------------------

- the default user is vagrant

- the password is vagrant

- that passwordless sudo is set for the default user

- that there is a ssh keypair in the keys directory named id_rsa

- that the public key is aded to the default users authorized_keys

Any changes to the box are defined in the setup.sh script, modify acording to your wishes.
In the autobuild script change the name of the box you're building and run :)