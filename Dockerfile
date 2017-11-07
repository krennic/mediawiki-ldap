FROM synctree/mediawiki

MAINTAINER Krennic

COPY entrypoint.sh /entrypoint.sh

# Cleanup mediawiki install
RUN set -x; \
    chmod 755 /entrypoint.sh && \

    set -x; \
    rm mediawiki.tar.gz mediawiki.tar.gz.sig && \

	# LDAP requirements
	set -x; \
    apt-get update && \
    apt-get install -y libldap2-dev && \
    rm -rf /var/lib/apt/lists/* && \

	# Install php ldap
	docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap && \

	# Prepare for installing extensions
  	set -x; \
    mkdir -p /usr/src/mediawiki/extensions  && \

	# Install LDAPAuthentication extension
	EXT_DL_URL="https://extdist.wmflabs.org/dist/extensions/LdapAuthentication-REL1_25-d4db6f0.tar.gz"; \
    EXT_TARBALL="ldapauth_ext.tar.gz"; \
    set -x; \
    curl -fSL "$EXT_DL_URL" -o "$EXT_TARBALL" && \
    tar -xf "$EXT_TARBALL" -C /usr/src/mediawiki/extensions && \
    rm "$EXT_TARBALL"  && \

	# Install Realnames extension
	EXT_DL_URL="http://ofbeaton.com/releases/Realnames/Realnames_0.3.1_2011-12-25.tar.gz"; \
    EXT_TARBALL="realnames_ext.tar.gz"; \
    set -x; \
    curl -fSL "$EXT_DL_URL" -o "$EXT_TARBALL" && \
    tar -xf "$EXT_TARBALL" -C /usr/src/mediawiki/extensions && \
    rm "$EXT_TARBALL"  && \

	# Fix issue with LdapAuthentication
	set -x; \
    sed -i 's/rtrim/trim/' /usr/src/mediawiki/extensions/LdapAuthentication/LdapAuthentication.php  && \

	# Be permissive about SSL certs
	set -x; \
    echo "TLS_REQCERT     never" >> /etc/ldap/ldap.conf 