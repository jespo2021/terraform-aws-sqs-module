# Terraform Module Lifecycle Management (SQS)
#
# This justfile is for MODULE DEVELOPMENT, TESTING, and RELEASE MANAGEMENT
# For actual AWS deployment and testing, see example usage under examples/
#
# Module Development Workflow:
#   just dev-check          # Validate module code
#   just test-github-latest # Test GitHub integration
#   just release 1.1.0      # Create new release
#
# Run 'just --list' to see all available commands

# Default recipe - shows help
default:
    @just --list
    @echo ""
    @echo "📋 Quick Reference:"
    @echo "  Module Development: just dev-check"
    @echo "  GitHub Testing:     just test-github-latest"
    @echo "  Release:            just release VERSION"

# =============================================================================
# DEVELOPMENT LIFECYCLE
# =============================================================================

# Format Terraform files
fmt:
    @echo "🎨 Formatting Terraform files..."
    terraform fmt -recursive

# Check Terraform formatting
fmt-check:
    @echo "🔍 Checking Terraform formatting..."
    terraform fmt -check -recursive

# Initialize Terraform (no backend)
init:
    @echo "🚀 Initializing Terraform..."
    terraform init -backend=false

# Upgrade Terraform providers to latest versions
upgrade:
    @echo "⬆️  Upgrading Terraform providers to latest versions..."
    terraform init -upgrade -backend=false
    @echo "✅ Providers upgraded! Check versions.tf for any needed updates."

# Validate Terraform configuration
validate:
    @echo "✅ Validating Terraform configuration..."
    terraform validate

# Validate all examples
validate-examples:
    @echo "📋 Validating all examples..."
    @for example in examples/*/; do \
        if [ -d "$$example" ]; then \
            echo "Validating $$example"; \
            (cd "$$example" && terraform init -backend=false && terraform validate); \
        fi; \
    done
    @echo "✅ All examples validated!"

# Run security scan
security:
    @echo "🔒 Running security scan..."
    @if command -v tfsec >/dev/null 2>&1; then \
        tfsec . --minimum-severity MEDIUM; \
    else \
        echo "⚠️  tfsec not installed. Install with: brew install tfsec"; \
    fi


# Full development check
dev-check: fmt validate validate-examples security
    @echo "✅ Development checks complete!"

# =============================================================================
# RELEASE LIFECYCLE
# =============================================================================

# Check if working directory is clean
check-clean:
    @echo "🔍 Checking git status..."
    @if [ -n "$$(git status --porcelain)" ]; then \
        echo "❌ Working directory has uncommitted changes:"; \
        git status --short; \
        exit 1; \
    else \
        echo "✅ Working directory is clean"; \
    fi

# Validate version format
validate-version version:
    @echo "🔍 Validating version format..."
    @if [[ "{{version}}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then \
        echo "✅ Version {{version}} is valid"; \
    else \
        echo "❌ Version must be in format X.Y.Z (no 'v' prefix)"; \
        exit 1; \
    fi

# Update CHANGELOG for new version
update-changelog version:
    @echo "📝 Updating CHANGELOG.md for version {{version}}..."
    @if [ ! -f CHANGELOG.md ]; then \
        echo "❌ CHANGELOG.md not found"; \
        exit 1; \
    fi
    @sed -i '' "s/## \[Unreleased\]/## [Unreleased]\n\n## [{{version}}] - $(date +%Y-%m-%d)/" CHANGELOG.md
    @echo "✅ CHANGELOG.md updated"

# Pre-release validation
pre-release version: check-clean (validate-version version) dev-check
    @echo "🚀 Pre-release validation complete for version {{version}}"

# Create and push release
release version: (pre-release version) (update-changelog version)
    @echo "🏷️  Creating release {{version}}..."
    git add CHANGELOG.md
    git commit -m "Release {{version}}: Update CHANGELOG"
    git tag -a {{version}} -m "Release {{version}}"
    git push origin main
    git push origin {{version}}
    @echo "🎉 Release {{version}} created and pushed!"
    @echo "📦 GitHub release will be created automatically by CI/CD"

# =============================================================================
# TESTING LIFECYCLE
# =============================================================================

# Test module from GitHub (latest)
test-github-latest:
    @echo "🧪 Testing module from GitHub (latest)..."
    @mkdir -p /tmp/test-sqs-module-latest
    @cd /tmp/test-sqs-module-latest && \
        echo 'terraform {' > main.tf && \
        echo '  required_version = "~> 1.12.0"' >> main.tf && \
        echo '  required_providers {' >> main.tf && \
        echo '    aws = { source = "hashicorp/aws", version = "~> 5.0" }' >> main.tf && \
        echo '  }' >> main.tf && \
        echo '}' >> main.tf && \
        echo 'provider "aws" { region = "us-east-1" }' >> main.tf && \
        echo 'module "test" {' >> main.tf && \
        echo '  source = "github.com/intervision/terraform-aws-sqs-module?ref=main"' >> main.tf && \
        echo '  queue_name = "test-queue"' >> main.tf && \
        echo '}' >> main.tf && \
        terraform init && terraform validate
    @echo "✅ GitHub latest test passed!"

# Test module from GitHub (specific version)
test-github-version version:
    @echo "🧪 Testing module from GitHub (version {{version}})..."
    @mkdir -p /tmp/test-sqs-module-{{version}}
    @cd /tmp/test-sqs-module-{{version}} && \
        echo 'terraform {' > main.tf && \
        echo '  required_version = "~> 1.12.0"' >> main.tf && \
        echo '  required_providers {' >> main.tf && \
        echo '    aws = { source = "hashicorp/aws", version = "~> 5.0" }' >> main.tf && \
        echo '  }' >> main.tf && \
        echo '}' >> main.tf && \
        echo 'provider "aws" { region = "us-east-1" }' >> main.tf && \
        echo 'module "test" {' >> main.tf && \
        echo '  source = "github.com/intervision/terraform-aws-sqs-module?ref={{version}}"' >> main.tf && \
        echo '  queue_name = "test-queue"' >> main.tf && \
        echo '}' >> main.tf && \
        terraform init && terraform validate
    @echo "✅ GitHub version {{version}} test passed!"

# =============================================================================
# CLEANUP & MAINTENANCE
# =============================================================================

# Clean Terraform files and directories
clean:
    @echo "🧹 Cleaning Terraform files..."
    rm -rf .terraform/
    rm -f .terraform.lock.hcl
    rm -f terraform.tfstate*
    rm -f *.tfplan
    @echo "✨ Terraform cleanup complete!"

# Clean examples
clean-examples:
    @echo "🧹 Cleaning example directories..."
    @for example in examples/*/; do \
        if [ -d "$$example" ]; then \
            echo "Cleaning $$example"; \
            (cd "$$example" && rm -rf .terraform/ .terraform.lock.hcl *.tfplan); \
        fi; \
    done
    @echo "✨ Examples cleanup complete!"

# Full cleanup
clean-all: clean clean-examples
    @echo "✨ Full cleanup complete!"

# =============================================================================
# UTILITY COMMANDS
# =============================================================================

# Show module info
info:
    @echo "📋 Module Information:"
    @echo "Repository: $$(git remote get-url origin 2>/dev/null || echo 'No remote configured')"
    @echo "Current branch: $$(git branch --show-current)"
    @echo "Latest tag: $$(git describe --tags --abbrev=0 2>/dev/null || echo 'No tags')"
    @echo "Terraform version: $$(cat .terraform-version 2>/dev/null || echo 'Not specified')"
    @echo "Examples: $$(ls -1 examples/ | wc -l | tr -d ' ') directories"
    @echo "Workflows: $$(ls -1 .github/workflows/*.yml 2>/dev/null | wc -l | tr -d ' ') files"

# Common workflows
dev: fmt validate validate-examples
    @echo "🎯 Development workflow complete!"

