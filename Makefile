.PHONY: test lint autocorrect build release clean reinstall_dependencies demo_build demo_serve plugin_publish plugin_yank

# Test the plugin
test:
	@bundle exec rake spec

# Run RuboCop to lint and check for style violations
lint:
	@bundle exec rake lint

# Run RuboCop with safe autocorrection
autocorrect:
	@echo "Running RuboCop with safe autocorrection..."
	@bundle exec rake autocorrect
	@echo "Safe autocorrection completed."

# Build the gem package
build:
	@bundle exec rake plugin:build

# Release the gem to RubyGems
release:
	@bundle exec rake plugin:publish

# Yank the gem from RubyGems
plugin_yank:
	@bundle exec rake plugin:yank

# Clean up generated files
clean:
	@bundle exec rake clean

# Task to clean and reinstall all gems
reinstall_dependencies:
	@echo "Cleaning unused gems..."
	@bundle clean --force
	@echo "Reinstalling all dependencies..."
	@bundle install
	@echo "All dependencies have been reinstalled successfully."

# Build the Jekyll demo site
demo_build:
	@bundle exec rake demo:build

# Serve the Jekyll demo site locally
demo_serve:
	@bundle exec rake demo:serve
