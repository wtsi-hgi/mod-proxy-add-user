proxy-add-user
===

## Introduction

Some authentication apache modules don't set the REMOTE_USER header field
during the fixup phase of the API. As a side effect, such headers can't be
dispatched to proxified applications as they are set too late. The only 
solution is to use a tricky module, registered between the authentication
process and the mod_proxy handler, which can retrieve the REMOTE_USER field
and set it to output headers, just before beeing send by mod_proxy.

As the result, REMOTE_USER can be catched even in proxified applications.

## Installation

  - Compile the module (./configure && make)
  - Copy the module to the apache module directory (/usr/lib/apache2/modules/)

Don't use a2enmod unless you know what you are doing, the order of loading 
is important (see Configuration).

## Configuration

Configuration of the module is tricky as it depends on the order on which
the modules are loaded. 

Extract of httpd.conf :

        LoadModule authopenid_module /usr/lib/apache2/modules/mod_auth_openid.so
        LoadModule proxy_add_user_module /usr/lib/apache2/modules/libproxy_add_user.so
        LoadModule proxy_module /usr/lib/apache2/modules/mod_proxy.so

The module has two settings working on a per directory basis (they can be
added to Proxy) :

  - ProxyAddUser to enable or not the module (on/off)
  - ProxyAddUserKey to customize the header key to be set (default is "X-REMOTE_USER")

Here is an example of configuration :

        <Proxy *>
         Order                  deny,allow
         Allow                  from all
         ProxyAddUser           On                 # Enable the module
         ProxyAddUserKey        "OpenID-IDENTITY"  # Set header field to OpenID-IDENTITY
         AuthOpenIDEnabled      On
        </Proxy>

## Security

You can't trust the X-REMOTE_USER header field unless you are *sure* your web
application can't be accessed only by the outside. Every http request *must*
pass by the proxy.
