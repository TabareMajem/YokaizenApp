# Vlog Therapy Admin Wizard - Complete Guide

This guide provides a comprehensive overview of the Vlog Therapy Admin Wizard - a Flutter-based tool that allows non-technical content creators to build interactive narrative experiences using the Flame Engine and Jenny dialogue system.

## Table of Contents

1. [Introduction](#introduction)
2. [System Architecture](#system-architecture)
3. [Implementation Guide](#implementation-guide)
4. [Component Breakdown](#component-breakdown)
5. [Extending the System](#extending-the-system)
6. [Deployment](#deployment)

## Introduction

The Vlog Therapy Admin Wizard is a specialized content management system designed to empower therapists, educators, and content creators to build interactive narrative experiences focused on mental wellbeing, self-esteem, and personal growth. The wizard allows non-technical users to create branching stories with:

- Interactive dialogue choices
- Character expressions and backgrounds
- Progress tracking via customizable stats
- Immediate deployment to mobile applications

By using this admin panel, content creators can focus on creating engaging therapeutic narratives without needing to understand the underlying code or game development concepts.

## System Architecture

The system consists of three main components:

1. **Admin Panel Wizard** (Flutter Web Application)
   - Provides a visual interface for creating interactive narratives
   - Allows previewing of content before deployment
   - Handles asset management (character images, backgrounds)

2. **Content Database & API**
   - Stores narrative content, including dialogue, characters, and scenes
   - Provides versioning and publishing controls
   - Delivers content to client applications

3. **Client Application**
   - Mobile app built with Flutter + Flame Engine
   - Consumes narratives using the Jenny dialogue system
   - Presents interactive experiences to end users

## Implementation Guide

### Prerequisites

To set up and run the Admin Wizard, you'll need:

- Flutter SDK (2.10.0 or higher)
- Firebase account (for authentication and database)
- A server to host your API (or Firebase Functions)
- Basic understanding of Flutter/Dart

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/vlog-therapy-admin
   cd vlog-therapy-admin
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new Firebase project
   - Enable Authentication and Firestore
   - Add your Firebase configuration to `lib/services/firebase_config.dart`

4. **Run the application**
   ```bash
   flutter run -d chrome --web-renderer html
   ```

## Component Breakdown

### Key Components

1. **Story Module Model**
   - Central data structure that represents an interactive story
   - Contains characters, scenes, dialogue nodes, and stats
   - Converts to/from JSON for API communication
   - Generates Yarn script for the Jenny dialogue system

2. **Dialogue Editor**
   - Visual node-based editor for creating branching narratives
   - Supports drag-and-drop node positioning
   - Visualizes connections between dialogue nodes

3. **Character Builder**
   - Interface for creating and managing characters
   - Supports multiple expressions per character
   - Handles image asset management

4. **Scene Designer**
   - Tool for creating and managing background scenes
   - Supports visual preview of scenes

5. **Content API**
   - Handles communication with backend services
   - Manages story deployment and retrieval

### How Components Work Together

1. Content creators use the wizard to build a story through a step-by-step process
2. The story data is structured in the `StoryModule` class 
3. When deployed, the story is converted to both:
   - JSON format for storage in the database
   - Yarn script format for consumption by the Jenny dialogue system
4. The client application fetches the story data and renders it using Flame + Jenny

## Extending the System

### Adding New Features

To extend the wizard with new capabilities:

1. **New Stat Types**
   - Modify the `Stat` class in `models/story_module.dart`
   - Add UI components in the stats editor tab
   - Update visualization components to display new stat types

2. **Additional Interactive Elements**
   - Extend the `DialogueNode` model to include new interactive features
   - Add corresponding UI controls in the node editor
   - Update the Jenny script generator to include new commands

3. **Custom Templates**
   - Create predefined story templates in `services/template_service.dart`
   - Add a template selection screen before the wizard begins
   - Implement template loading logic in the admin state

### Customizing the UI

The admin panel uses Flutter's Material Design by default, but can be customized:

1. **Theming**
   - Modify the theme settings in `main.dart`
   - Create custom widget themes in a separate theme file
   - Use your organization's branding colors and typography

2. **Layout Adjustments**
   - The wizard uses a responsive design that adapts to different screen sizes
   - Modify the layout constants in `constants/layout.dart` to adjust spacing
   - Create alternative layouts for different device types

## Deployment

### Deploying the Admin Panel

1. **Web Deployment**
   ```bash
   flutter build web --release
   ```
   - Deploy the contents of the `build/web` directory to any web hosting service
   - Configure Firebase hosting for seamless authentication

2. **Desktop Application** (for internal use)
   ```bash
   flutter build windows --release  # Or macos, linux
   ```
   - Package the application with appropriate installers for your platform
   - Distribute to content team members

### API Deployment

The Content API can be deployed in several ways:

1. **Firebase Functions**
   - Implement the API endpoints as Firebase Cloud Functions
   - Use Firestore triggers for automated processes like validation

2. **Standalone Server**
   - Deploy the API as a Node.js, Python, or other backend service
   - Use containerization (Docker) for easier deployment

3. **Serverless Options**
   - AWS Lambda + API Gateway
   - Google Cloud Functions
   - Azure Functions

### Client App Integration

To integrate the generated content into your client application:

1. Add the Flame Engine and Jenny dialogue system to your Flutter project
2. Implement a content fetching service that retrieves stories from your API
3. Create a dialogue runner that processes the Jenny scripts
4. Build UI components that render the dialogue, characters, and scenes
5. Implement the progress tracking system based on the defined stats

## Best Practices

### Content Creation Guidelines

When creating therapeutic content:

1. **Focus on Authenticity**: Create dialogue that sounds natural and relatable
2. **Provide Meaningful Choices**: Each choice should feel significant and lead to different outcomes
3. **Balance Challenge and Support**: Create experiences that challenge users but also provide supportive guidance
4. **Include Reflection Moments**: Add nodes that encourage users to reflect on their choices and progress
5. **Test with Target Audience**: Have representative users test the experience and provide feedback

### Technical Best Practices

1. **Version Control**: Use semantic versioning for your story modules
2. **Regular Backups**: Implement automatic backups of your content database
3. **Validation**: Add validation rules to prevent publishing incomplete or broken stories
4. **Analytics**: Integrate usage analytics to understand how users interact with your content
5. **Modular Design**: Create reusable components that can be shared between different stories

## Troubleshooting

### Common Issues

1. **Preview Not Matching Published Content**
   - Check that all assets are properly uploaded and accessible
   - Verify that the client app has the latest version of the content

2. **Dialogue Flow Problems**
   - Use the graph view to check for disconnected nodes or dead ends
   - Verify that all choice options lead to valid target nodes

3. **Performance Issues**
   - Large story modules with many nodes may cause performance problems
   - Consider breaking very large stories into smaller, connected modules

4. **Asset Management**
   - Use consistent naming conventions for image files
   - Optimize images for mobile devices to reduce bandwidth usage

## Support and Resources

### Documentation

- [Flame Engine Documentation](https://docs.flame-engine.org/)
- [Jenny Dialogue System](https://docs.flame-engine.org/latest/other_modules/jenny/runtime/jenny_runtime.html)
- [Flutter Web Development](https://flutter.dev/docs/development/platform-integration/web)

### Community and Support

- Join the [Flame Engine Discord](https://discord.com/invite/pxrBmy4) for technical support
- Contact our team at support@vlogtherapy.example.com for admin panel specific questions

---

This Admin Wizard empowers content creators to build engaging interactive narratives for mental wellbeing without requiring technical expertise. By combining the power of Flutter, Flame Engine, and the Jenny dialogue system, your team can quickly create, test, and deploy therapeutic content directly to users.