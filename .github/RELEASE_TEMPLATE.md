# Release Checklist

Use this checklist when preparing a new release of the AWS SQS Terraform Module.

## Pre-Release Checklist

### 🔍 Code Quality
- [ ] All CI checks are passing on main branch
- [ ] Security scan (Checkov) shows no critical issues
- [ ] All examples validate successfully
- [ ] Code is properly formatted (`terraform fmt`)
- [ ] Variable validations are working correctly

### 📚 Documentation
- [ ] CHANGELOG.md updated with new version and changes
- [ ] README.md reflects current features
- [ ] All examples have current documentation
- [ ] Variable descriptions are accurate and complete

### 🧪 Testing
- [ ] All examples can be planned without errors
- [ ] Variable validation tests pass
- [ ] Manual testing completed in sandbox environment
- [ ] Integration tests pass (if available)

### 🏷️ Version Management
- [ ] Version follows semantic versioning (MAJOR.MINOR.PATCH)
- [ ] Version is consistent across all documentation
- [ ] Breaking changes are clearly documented
- [ ] Migration guide updated (if needed)

## Release Process

### 1. Prepare Release Branch
```bash
# Create release branch
git checkout -b release/1.1.0
git push -u origin release/1.1.0
```

### 2. Update Version Information
- [ ] Update CHANGELOG.md with release date
- [ ] Update version references in documentation
- [ ] Update any version-specific examples

### 3. Final Testing
```bash
# Test the module
terraform init -backend=false
terraform validate
just dev-check
```

### 4. Create Release PR
- [ ] Create PR from release branch to main
- [ ] Ensure all CI checks pass
- [ ] Get approval from code owners
- [ ] Merge to main

### 5. Create Release Tag
```bash
# Create and push tag
git checkout main
git pull origin main
git tag -a 1.1.0 -m "Release 1.1.0"
git push origin 1.1.0
```

### 6. Verify Release
- [ ] GitHub release created automatically
- [ ] Release notes generated correctly
- [ ] All workflows completed successfully

## Post-Release Checklist

### 📢 Communication
- [ ] Announce release in team channels
- [ ] Update internal documentation
- [ ] Notify dependent projects
- [ ] Update project roadmap

### 🔄 Maintenance
- [ ] Monitor for issues in first 24 hours
- [ ] Address any immediate feedback
- [ ] Plan next release cycle
- [ ] Update project boards/issues

## Release Types

### 🔴 Major Release (x.0.0)
- Breaking changes to module interface
- Requires migration guide
- Extended testing period
- Advance notice to users

### 🟡 Minor Release (x.y.0)
- New features
- Backward compatible changes
- Enhanced functionality
- Standard testing process

### 🟢 Patch Release (x.y.z)
- Bug fixes
- Security updates
- Documentation improvements
- Minimal testing required

## Rollback Plan

If issues are discovered after release:

### Immediate Actions
1. [ ] Create hotfix branch from previous stable tag
2. [ ] Apply minimal fix
3. [ ] Test fix thoroughly
4. [ ] Create patch release
5. [ ] Communicate issue and resolution

### Communication
- [ ] Notify users of issue
- [ ] Provide workaround if available
- [ ] Announce fix timeline
- [ ] Document lessons learned

## Version History Template

Add to CHANGELOG.md:

```markdown
## [1.1.0] - 2025-09-04

### Added
- New feature descriptions
- Enhanced functionality

### Changed
- Modified behavior descriptions
- Updated dependencies

### Fixed
- Bug fix descriptions
- Security improvements

### Deprecated
- Features marked for removal

### Removed
- Removed features (breaking changes)

### Security
- Security-related changes
```

## Notes

- Always test releases in a sandbox environment first
- Keep release notes user-focused and clear
- Include migration instructions for breaking changes
- Monitor GitHub Issues and Discussions after release
- Consider creating a release candidate for major versions

---

**Release Manager:** @jespo2021
**Review Required:** Yes
**Approval Required:** Yes
