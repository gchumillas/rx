SRC = main.v
VMODULES_DIR := $(shell if [ -n "$$VMODULES" ]; then echo "$$VMODULES"; else echo "~/.vmodules"; fi)

# Install | Uninstall this package locally for dev
install:
	ln -s $(CURDIR) $(VMODULES_DIR)
uninstall:
	rm $(VMODULES_DIR)/rx

# Example_1 tasks
EXAMPLE_1_DIR = $(CURDIR)/examples/example_1

e1.run:
	v run $(EXAMPLE_1_DIR)

# Example_2 tasks
EXAMPLE_2_DIR = $(CURDIR)/examples/example_2

e2.build:
	v -b js_browser $(EXAMPLE_2_DIR)/main.v
e2.open:
	@if [ ! -f $(EXAMPLE_2_DIR)/main.js ]; then \
		$(MAKE) e2.build; \
	fi
	open $(EXAMPLE_2_DIR)/index.html

# Run tests
test:
	v test .

# Format source code
fmt:
	v fmt -w .
