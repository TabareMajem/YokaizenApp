# Vlog Therapy Admin Wizard - Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────┐
│             Admin Panel Wizard          │
├─────────────────────┬───────────────────┤
│  Content Creation   │ Content Management│
│  - Story Editor     │ - Asset Library   │
│  - Character Builder│ - Version Control │
│  - Scene Designer   │ - Analytics       │
└─────────┬───────────┴─────────┬─────────┘
          │                     │
          ▼                     ▼
┌─────────────────┐    ┌──────────────────┐
│  Content API    │    │ Content Database │
│  - REST/GraphQL │    │ - Firebase       │
│  - Auth         │    │ - Story Modules  │
└─────────┬───────┘    └────────┬─────────┘
          │                     │
          └──────────┬──────────┘
                     │
                     ▼
┌─────────────────────────────────────────┐
│        Client Application               │
├─────────────────────────────────────────┤
│  - Flutter + Flame Engine              │
│  - Jenny Dialogue System               │
│  - Dynamic Content Loading             │
└─────────────────────────────────────────┘
```

## Key Components

### 1. Admin Panel Wizard (Flutter Web Application)

A multi-step content creation wizard built with Flutter Web that guides administrators through the process of creating interactive narratives without coding.

### 2. Content Database & API

Backend infrastructure to store, version, and deliver narrative content to the client application.

### 3. Client Application

The mobile application that consumes the generated content and presents it to users using Flame Engine and Jenny dialogue system.

## Data Flow

1. Content creators use the Admin Wizard to design narratives, characters, and interactive elements
2. The wizard generates standardized JSON/YAML configurations compatible with Jenny and Flame
3. Content is stored in the database with versioning
4. Client applications fetch content via API and render it using pre-built Flame/Jenny components
5. Analytics about user interaction flows back to the admin panel for content optimization
