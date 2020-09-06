compile_coffee_files:
	coffee --compile --output js/ coffee/
clean:
	@echo "Cleaning up..."
	rm js/*
	rmdir js
	
