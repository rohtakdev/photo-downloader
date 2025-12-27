# Documentation Overview

This directory contains the complete documentation for the macOS iCloud Data Export Download Manager application.

## Document Structure

### [app-spec.md](./app-spec.md)
**Application Specification** - Complete functional and non-functional requirements, data models, error scenarios, and acceptance criteria. This is the definitive specification document that defines what the application should do.

**When to read**: Start here to understand the application's requirements and expected behavior.

### [app-architecture.md](./app-architecture.md)
**Application Architecture** - Technical architecture, component breakdown, data flow, and system design. Describes how the application is structured and how components interact.

**When to read**: Use this when implementing features or understanding the system design.

### [project-plan.md](./project-plan.md)
**Project Plan** - Phased implementation plan with milestones, dependencies, and deliverables. Provides the roadmap for building the application.

**When to read**: Reference this to understand the implementation timeline and phase dependencies.

### [developer-guide.md](./developer-guide.md)
**Developer Guide** - Setup instructions, development workflow, conventions, and common pitfalls. Practical guidance for developers working on the project.

**When to read**: Use this when setting up your development environment or during active development.

### [test-plan.md](./test-plan.md)
**Test Plan** - Testing strategy, test cases, success criteria, and automation approach. Defines how the application will be validated.

**When to read**: Reference this when writing tests or planning QA activities.

### [ARCHITECTURE_REVIEW.md](./ARCHITECTURE_REVIEW.md)
**Architecture Review** - Comprehensive architecture analysis, identified issues, and recommendations. Documents the architecture review process and improvements made.

**When to read**: Review this to understand architectural decisions, issues that were addressed, and the rationale behind the current architecture.

### [ARCHITECTURE_DIAGRAMS.md](./ARCHITECTURE_DIAGRAMS.md)
**Architecture Diagrams** - Visual representations of the architecture, including current state, recommended improvements, and data flow diagrams.

**When to read**: Use this for visual understanding of the architecture, component relationships, and data flows. Also see [view-diagrams.html](./view-diagrams.html) for an interactive viewer.

## Documentation Workflow

### When to Update Documentation

- **app-spec.md**: Update when requirements change or new features are added
- **app-architecture.md**: Update when components are added/modified or data flow changes
- **project-plan.md**: Update when phases or milestones change, or timeline adjustments are made
- **developer-guide.md**: Update when setup steps change, new conventions are established, or folder structure changes
- **test-plan.md**: Update when new test cases are added, testing tools change, or test strategy evolves

### Documentation Maintenance

1. Keep documents synchronized - changes in one document may require updates in others
2. Update cross-references when restructuring
3. Maintain consistency in terminology across all documents
4. Review documentation during code reviews for accuracy

## Quick Reference

### For New Developers
1. Read `app-spec.md` to understand requirements
2. Read `app-architecture.md` to understand the system design
3. Follow `developer-guide.md` to set up your environment
4. Reference `project-plan.md` to see current phase and priorities

### For Project Planning
1. Review `project-plan.md` for phase breakdown and dependencies
2. Reference `app-spec.md` for feature requirements
3. Check `test-plan.md` for testing requirements per phase

### For Implementation
1. Check `app-architecture.md` for component design
2. Follow `developer-guide.md` for conventions and best practices
3. Reference `app-spec.md` for acceptance criteria
4. Update relevant docs as implementation progresses

## Document Relationships

```
app-spec.md (What)
    ↓
app-architecture.md (How)
    ↓
project-plan.md (When/Order)
    ↓
developer-guide.md (How to build)
    ↓
test-plan.md (How to validate)
```

## Version History

Documentation should be versioned alongside the codebase. Major changes to architecture or requirements should be noted in commit messages and may warrant version tags in the documentation.

