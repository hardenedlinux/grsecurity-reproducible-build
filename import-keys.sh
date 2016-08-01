#! /bin/bash

# Greg Kroah-Hartman (Linux kernel stable release signing key) <greg@kroah.com>
gpg --recv-keys 38DBBDC86092693E # Linux
# Tristan Gingold <gingold@adacore.com>
gpg --recv-keys C3126D3B4AE55E93 # Binutils
# Jakub Jelinek <jakub@redhat.com>
gpg --recv-keys A328C3A2C3C45C06 # GCC
# Niels Möller <nisse@lysator.liu.se>
gpg --recv-keys F3599FF828C67298 # GMP
# Vincent Lefevre <vincent@vinc17.net>
gpg --recv-keys 980C197698C3739D # MPFR
# Andreas Enge <andreas.enge@inria.fr>
gpg --recv-keys F7D5C9BF765C61E3 # MPC
