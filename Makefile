APXS=`which apxs2`
RM=`which rm` -f
MKDIR=`which mkdir`
APACHE_MOD_AVAILABLE_DIR=/etc/apache2/mods-available
APACHE_MOD_BIN_DIR=/usr/lib/apache2/modules

all: proxy_add_user shib2_proxy_add_user_proxy.load

proxy_add_user: proxy_add_user.c
	$(APXS) -c proxy_add_user.c

shib2_proxy_add_user_proxy.load:  $(APACHE_MOD_AVAILABLE_DIR)/shib2.load $(APACHE_MOD_AVAILABLE_DIR)/proxy.load $(APACHE_MOD_AVAILABLE_DIR)/proxy_http.load
	(echo "# auth module must be loaded first, followed by proxy_add_user, then proxy and proxy_http" && (cat $(APACHE_MOD_AVAILABLE_DIR)/shib2.load && echo "LoadModule proxy_add_user_module /usr/lib/apache2/modules/proxy_add_user.so" && cat $(APACHE_MOD_AVAILABLE_DIR)/proxy.load $(APACHE_MOD_AVAILABLE_DIR)/proxy_http.load | grep -v '^#')) > shib2_proxy_add_user_proxy.load 

clean:
	$(RM) *.la *.lo *.slo *.load
	$(RM) -r .libs

install: all
	$(MKDIR) -p $(APACHE_MOD_BIN_DIR)
	$(APXS)  -S LIBEXECDIR=$(APACHE_MOD_BIN_DIR)/ -ci proxy_add_user.c
	cp shib2_proxy_add_user_proxy.load $(APACHE_MOD_AVAILABLE_DIR)/shib2_proxy_add_user_proxy.load
