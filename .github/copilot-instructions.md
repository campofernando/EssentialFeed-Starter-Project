# GitHub Copilot Instructions

This file contains guidelines and instructions for GitHub Copilot when working with this project.

## Project Overview

EssentialFeed is an iOS application that implements a feed loading system with caching, API integration, and image loading capabilities.

## Key Architecture Patterns

- **Dependency Injection**: Used throughout for loose coupling and testability
- **Composition Pattern**: Used in `FeedUIComposer` for composing view controllers
- **Spy Pattern**: Used in tests for tracking method calls and managing completions

## Testing Conventions

- Integration tests use helper methods like `makeSUT()` for test setup
- Loader spies are used to mock feed loading and image loading operations
- View controller extensions provide simulation methods for user interactions
- Memory leak tracking is implemented in test teardown

## Code Style Guidelines

- Follow Swift naming conventions (camelCase for methods/properties, PascalCase for types)
- Use `final` for test classes to prevent accidental subclassing
- Include descriptive assertion messages explaining expected vs actual behavior
- Organize test methods by functionality with MARK comments

## When Generating Code

- Maintain consistency with existing patterns (spies, helpers, extensions)
- Ensure all view controller methods have corresponding simulation methods in test extensions
- Include localization keys for user-facing strings
- Implement proper error handling and background thread dispatch
- Add memory leak tracking for all created objects in tests

## File Organization

- `/EssentialFeed/Feed Feature/` - Core domain models
- `/EssentialFeed/Feed API/` - Remote feed loading and HTTP client
- `/EssentialFeed/Feed Cache/` - Local feed caching with Core Data and Codable options
- `/EssentialFeediOS/` - iOS-specific presentation and UI components
- `/EssentialFeediOSTests/` - Integration tests for UI components
- `/EssentialFeedTests/` - Unit tests for core functionality
