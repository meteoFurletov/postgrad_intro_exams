---
name: "Postgraduate Exam Preparation Site"
description: "Jekyll-based academic notes site for physics exam preparation with interactive note exploration and responsive design"
category: "Academic Documentation"
author: "Nikita Furletov"
authorUrl: "https://github.com/meteofurletov/"
repository: "https://github.com/meteofurletov/postgrad_intro_exams"
tags:
  [
    "jekyll",
    "github-pages",
    "academic",
    "notes",
    "markdown",
    "responsive-design",
    "physics",
    "education",
  ]
lastUpdated: "2025-08-17"
---

# Postgraduate Exam Preparation Site - Project Knowledge

## Project Overview

This is an academic note website for postgraduate physics exam preparation, built with Jekyll and hosted on GitHub Pages. The site provides an interactive interface for exploring physics topics with both compact overview notes and detailed hierarchical content. Features include responsive design with mobile collapsible sidebar, MathJax mathematical rendering, and dynamic note loading for seamless navigation.

**Live Site**: <https://meteofurletov.github.io/postgrad_intro_exams/>
**Repository**: <https://github.com/meteofurletov/postgrad_intro_exams>

## Tech Stack and Architecture

- **Static Site Generator**: Jekyll 4.0+ with Minima theme
- **Hosting**: GitHub Pages with automated GitHub Actions deployment
- **Content Format**: Markdown with Kramdown parser and YAML front matter
- **Styling**: SCSS with responsive CSS Grid layout and mobile-first design
- **Math Rendering**: MathJax 3.0+ for mathematical expressions and formulas
- **JavaScript**: Vanilla JS for interactive note explorer and mobile interactions
- **CI/CD**: GitHub Actions workflow for automated building and deployment
- **Development**: Docker-based Jekyll environment for consistent builds

## Project Structure and Organization

The project follows a hierarchical academic content structure optimized for physics exam preparation:

```text
├── _config.yml                 # Jekyll site configuration with baseurl="/postgrad_intro_exams"
├── index.html                  # Redirect to notes.html interface
├── notes.html                  # Main interactive notes interface with mobile sidebar
├── _includes/
│   ├── head.html              # Custom CSS loading and MathJax configuration
│   ├── notes-explorer.html    # Interactive navigation tree with search
│   └── physics-nav.html       # Subject-specific navigation component
├── _layouts/
│   ├── default.html           # Base layout with MathJax support
│   └── physics.html           # Physics-specific topic layout
├── assets/
│   ├── main.scss              # Global styles with academic typography
│   └── notes.css              # Notes interface with responsive mobile sidebar
└── Notes/                     # Unified notes structure with theme-level and detailed content
    ├── Блок 1. «Физика атмосферы»/
    │   ├── 1.1. Тема «Строение, состав, свойства атмосферы».md  # Theme overview
    │   ├── 1.1. Тема «Строение, состав, свойства атмосферы»/   # Detailed breakdown
    │   │   ├── 1.1.1 Предмет и метод метеорологии.md
    │   │   ├── 1.1.2 Основные метеорологические величины.md
    │   │   └── ...            # Additional detailed subtopics
    │   ├── 1.2. Тема «Статика и термодинамика атмосферы».md    # Theme overview
    │   ├── 1.2. Тема «Статика и термодинамика атмосферы»/      # Detailed breakdown
    │   └── ...                # Additional physics themes
    └── Блок 2. «Динамическая метеорология»/
        ├── 2.1. Тема «Силы, действующие в атмосфере»/
        └── ...                # Additional dynamics topics
```

### Content Structure Principles

- **Unified Organization**: All content organized under `Notes/` folder with block-level structure
- **Theme-Level Overviews**: Compact `.md` files directly in block folders provide quick topic summaries
- **Detailed Breakdowns**: Matching folders contain comprehensive subtopic coverage
- **Hierarchical Navigation**: Interactive tree explorer shows both overview and detailed content
- **Russian Academic Naming**: Authentic Russian physics terminology and curriculum structure
- **Cross-Referencing**: Internal links between related topics and concepts
- **Mathematical Content**: Extensive use of LaTeX formulas via MathJax rendering

## Key Features and Components

### Interactive Notes Explorer

- **Dynamic Tree Navigation**: JavaScript-based hierarchical exploration of physics topics
- **Search Functionality**: Real-time filtering of notes by content and title
- **Mobile-Responsive Sidebar**: Collapsible sidebar with hamburger menu for mobile devices
- **Note Loading System**: AJAX-based dynamic loading of Markdown content without page refresh
- **Active State Management**: Visual indication of currently selected notes

### Responsive Design System

- **Mobile-First Approach**: CSS Grid layout optimized for various screen sizes
- **Collapsible Mobile Interface**: Toggle sidebar with overlay for mobile usability
- **Touch-Friendly Interactions**: Optimized button sizes and touch targets for mobile devices
- **CSS Animations**: Smooth transitions for sidebar toggling and interactive elements

### Academic Content Features

- **Mathematical Rendering**: MathJax integration for complex physics formulas and equations
- **Cross-Reference System**: Internal linking between related topics and concepts
- **Academic Typography**: Proper formatting for scientific content and Russian text
- **Print Optimization**: CSS print styles for academic paper printing

### Content Management

- **YAML Front Matter**: Structured metadata for all academic content
- **Hierarchical Organization**: Logical topic progression following physics curriculum
- **Version Control**: Git-based content management with collaborative editing
- **Automated Deployment**: GitHub Actions for continuous integration and deployment

## Configuration and Deployment

### Important Configuration Details

- **Site Base URL**: `/postgrad_intro_exams` (required for GitHub Pages project site)
- **Jekyll Theme**: Minima with custom overrides for academic content
- **Math Engine**: MathJax 3.0+ configured for LaTeX mathematical expressions
- **Language**: Russian (ru) for proper text processing and academic terminology
- **Mobile Breakpoint**: 900px for responsive sidebar behavior

### Deployment Workflow

- **Automated CI/CD**: GitHub Actions builds and deploys on every push to main branch
- **Ruby Environment**: Version 3.1 with bundler caching for consistent builds
- **Production Environment**: JEKYLL_ENV=production for optimized builds
- **Asset Processing**: SCSS compilation with Jekyll front matter

### Key Features Implementation Status

- ✅ **Mobile Responsive Interface**: Collapsible sidebar with hamburger menu
- ✅ **Interactive Notes Explorer**: Dynamic tree navigation with search
- ✅ **Mathematical Content**: MathJax rendering with LaTeX support
- ✅ **Academic Typography**: Proper formatting for physics content
- ✅ **Cross-Reference System**: Internal linking between topics
- ✅ **Performance Optimization**: Client-side caching and progressive loading

## Development Guidelines

### File Naming Conventions

- **Academic Content**: Use descriptive Russian topic names matching curriculum structure
- **Layouts**: PascalCase for Jekyll layout and include files
- **CSS Classes**: kebab-case for styling and JavaScript targeting
- **Variables**: snake_case for Jekyll configuration and Liquid templates

### Content Management Workflow

- **Unified Structure**: Maintain both theme overviews (`.md` files) and detailed breakdowns (folders) in `Notes/` directory
- **YAML Front Matter**: Required for all content files with proper metadata
- **Mathematical Content**: Use `math: true` flag for pages with LaTeX formulas
- **Cross-References**: Implement internal links using relative paths
- **Version Control**: Git-based workflow with descriptive commit messages

### Mobile Optimization Considerations

- **Touch Targets**: Minimum 44px for mobile interaction elements
- **Sidebar Width**: 80% screen width on mobile for usability
- **Overlay System**: Semi-transparent background for modal behavior
- **Escape Handling**: Keyboard accessibility with Escape key support
- **Performance**: CSS transforms for smooth animations on mobile devices

## Known Issues and Solutions

### Mobile Sidebar Implementation

- **Problem**: CSS rule conflicts between desktop and mobile styles
- **Solution**: Proper media query ordering with mobile-first approach
- **Key Fix**: Place mobile styles after desktop styles in CSS cascade

### MathJax Rendering

- **Integration**: Conditional loading based on page front matter
- **Performance**: Async loading with polyfill support for older browsers
- **Rendering**: Re-render after dynamic content loading

### Academic Content Structure

- **Russian Text Encoding**: UTF-8 encoding for proper Cyrillic character support
- **Academic Formatting**: Custom CSS for scientific notation and formulas
- **Print Optimization**: Specialized print styles for academic paper printing

This project serves as a comprehensive example of Jekyll-based academic website development with specific focus on physics exam preparation, responsive design, and mathematical content presentation.
