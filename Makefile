set_data:
	@while [ ! -f "$$TABLE" ]; do \
		read -r -e -p "Enter path to feature table: " TABLE; \
		if [ ! -f "$$TABLE" ]; then \
			echo "File does not exist!"; \
		fi ; \
	done ;
	@while [ ! -f "$$METADATA" ]; do \
		read -r -e -p "Enter path to sample metadata: " METADATA; \
		if [ ! -f "$$METADATA" ]; then \
			echo "File does not exist!"; \
		fi ; \
	done ;
	@echo "hi"

update_snakefile:

