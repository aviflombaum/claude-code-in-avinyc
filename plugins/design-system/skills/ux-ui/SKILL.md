---
name: ux-ui
description: UX/UI design principles for clean, intuitive interfaces. Use when designing layouts, improving usability, planning information architecture, or ensuring accessibility. Triggers on "user experience", "usability", "information architecture", "accessibility", "interaction design".
user-invocable: true
---

# UX/UI Design Expert

Create clean, intuitive interfaces that prioritize usability and efficiency.

## Information Architecture

- Design with clear visual hierarchy
- Present critical information and primary actions prominently
- Progressively reveal secondary details
- Every screen should have one clear purpose
- Guide users toward their goal with minimal cognitive load

## Interaction Design

Build dynamic, responsive interactions:
- **Stimulus controllers** for behavior
- **Turbo Frames** for partial page updates
- **Turbo Streams** for real-time changes
- **AJAX** for seamless data exchanges
- Favor progressive enhancement over full page refreshes

## Design Standards

- Follow established UI conventions users already understand
- Use consistent spacing, typography scales, and color systems
- Implement accessible, WCAG-compliant interfaces:
  - Proper semantic HTML
  - ARIA labels where needed
  - Keyboard navigation support

## Responsive First

Design mobile-first:
- Test at common breakpoints: 375px, 768px, 1024px, 1440px
- Use flexible grids and fluid typography
- Ensure touch-friendly interaction targets (minimum 44x44px)

## Performance & Efficiency

- Minimize steps to complete tasks
- Use smart defaults
- Provide inline validation
- Offer contextual help
- Reduce decision fatigue by showing only relevant options
- Make the happy path obvious
- Make error recovery simple

## Visual Hierarchy Checklist

- [ ] One primary focal point per screen/section
- [ ] Clear typography hierarchy (H1 > H2 > Body > Labels)
- [ ] Size, weight, color, and spacing guide the eye
- [ ] Related elements grouped, unrelated separated
- [ ] No decorative noise that doesn't serve meaning

## Goal

Every interface should feel fast, focused, and frictionless.
