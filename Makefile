SRC = main.v
VMODULES_DIR := $(shell if [ -n "$$VMODULES" ]; then echo "$$VMODULES"; else echo "~/.vmodules"; fi)

# Install | Uninstall this package locally for dev
install:
	ln -s $(CURDIR) $(VMODULES_DIR)
uninstall:
	rm $(VMODULES_DIR)/$(notdir $(CURDIR))
