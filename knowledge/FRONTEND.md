# Frontend Design Patterns

This document outlines frontend design patterns and principles for the agents-skills repository.

## Supported Frameworks

### Angular (v20+)

- Standalone components with signal-based inputs/outputs
- OnPush change detection
- Resource-based HTTP patterns
- Signal-based reactive state management
- Server-side rendering with @angular/ssr

### Blazor

- Fluent UI components
- AbpComponentBase patterns
- DataGrid patterns
- Dialog and Toast patterns

### React

- Modern component patterns
- Signal-based state (where applicable)
- Server components (where applicable)

## Frontend Architecture Principles

### Component Design

- **Single Responsibility**: Each component does one thing well
- **Composition over Inheritance**: Prefer composition patterns
- **Signal-Based**: Use signals for reactive state where available
- **Accessible**: Follow WCAG guidelines
- **Performant**: Lazy loading, code splitting, virtualization

### State Management

- **Local State First**: Use local component state when possible
- **Lift State When Necessary**: Only lift to parent when shared
- **Server State**: Use resource patterns for server data
- **Global State**: Use signals/store for truly global state

### Data Fetching

- **Resource Pattern**: Use resource() for HTTP data
- **Optimistic Updates**: Update UI immediately, rollback on error
- **Error Boundaries**: Handle errors gracefully
- **Loading States**: Show loading indicators appropriately

## UI Patterns

### Forms

- **Signal Forms**: Use signal-based form APIs where available
- **Validation**: Schema-based validation
- **Accessibility**: Proper labels, error messages, keyboard navigation
- **Progressive Enhancement**: Work without JavaScript where possible

### Navigation

- **Lazy Loading**: Load routes on demand
- **Route Guards**: Functional guards for protection
- **Resolvers**: Load data before route activation
- **Query Parameters**: Use signals for route parameters

## Performance Guidelines

- **Bundle Size**: Keep bundles under 200KB gzipped
- **Time to Interactive**: Under 3 seconds
- **First Contentful Paint**: Under 1.5 seconds
- **Lighthouse Score**: 90+ across all categories

## Accessibility

- **Keyboard Navigation**: All interactive elements keyboard accessible
- **Screen Readers**: Proper ARIA labels and roles
- **Color Contrast**: WCAG AA compliant (4.5:1)
- **Focus Management**: Visible focus indicators, logical tab order
- **Error Handling**: Clear error messages, recovery options

## Testing

- **Unit Tests**: Component logic and state management
- **Integration Tests**: Component interactions
- **E2E Tests**: Critical user journeys
- **Visual Regression**: UI consistency across changes

## Browser Support

- **Modern Browsers**: Latest Chrome, Firefox, Safari, Edge
- **Progressive Enhancement**: Degrade gracefully for older browsers
- **Mobile**: Responsive design, touch-friendly interactions
