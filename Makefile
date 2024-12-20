.PHONY: test lint autocorrect build release clean reinstall_dependencies

# Test the plugin
test:
	@bundle exec rake spec

# Run RuboCop to lint and check for style violations
lint:
	@bundle exec rake rubocop

# Run RuboCop with safe autocorrection
autocorrect:
	@echo "Running RuboCop with safe autocorrection..."
	@bundle exec rubocop -a
	@echo "Safe autocorrection completed."

# Build the gem package
build:
	@bundle exec rake build

# Release the gem to RubyGems
release:
	@bundle exec rake release

# Clean up generated files
clean:
	@rm -rf pkg/
	@find . -name "*.gem" -delete

# Task to clean and reinstall all gems
reinstall_dependencies:
	@echo "Cleaning unused gems..."
	@bundle clean --force
	@echo "Reinstalling all dependencies..."
	@bundle install
	@echo "All dependencies have been reinstalled successfully."
