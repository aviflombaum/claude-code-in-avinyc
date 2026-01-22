---
name: tailwind
description: Tailwind CSS patterns, utilities, and component styling for Rails. Use when styling with Tailwind, creating responsive layouts, or building UI components. Triggers on "tailwind", "style with", "css classes", "responsive layout".
argument-hint: "[component|layout|pattern] description"
user-invocable: true
---

# Tailwind CSS Expert

Expert Tailwind CSS patterns for building modern, responsive interfaces.

## Core Principles

1. **Utility-first**: Compose designs directly in markup using utility classes
2. **Responsive by default**: Mobile-first with `sm:`, `md:`, `lg:`, `xl:`, `2xl:` prefixes
3. **Consistent spacing**: Use the spacing scale (4, 8, 12, 16, 20, 24, 32, 40, 48, 64)
4. **Design tokens**: Leverage the default theme or extend it consistently

## Common Patterns

### Layout
```html
<!-- Flexbox centering -->
<div class="flex items-center justify-center">

<!-- Grid layout -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">

<!-- Container with padding -->
<div class="container mx-auto px-4 sm:px-6 lg:px-8">
```

### Typography
```html
<!-- Headings -->
<h1 class="text-3xl font-bold tracking-tight text-gray-900">
<h2 class="text-2xl font-semibold text-gray-800">
<p class="text-base text-gray-600 leading-relaxed">

<!-- Truncation -->
<p class="truncate">  <!-- Single line -->
<p class="line-clamp-3">  <!-- Multi-line -->
```

### Buttons
```html
<!-- Primary -->
<button class="px-4 py-2 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors">

<!-- Secondary -->
<button class="px-4 py-2 bg-white text-gray-700 font-medium rounded-lg border border-gray-300 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors">
```

### Cards
```html
<div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
  <h3 class="text-lg font-semibold text-gray-900">Title</h3>
  <p class="mt-2 text-gray-600">Description</p>
</div>
```

### Forms
```html
<label class="block text-sm font-medium text-gray-700">Email</label>
<input type="email" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm">
```

## Responsive Design

```html
<!-- Stack on mobile, side-by-side on larger screens -->
<div class="flex flex-col sm:flex-row gap-4">

<!-- Hide on mobile, show on desktop -->
<div class="hidden lg:block">

<!-- Different padding at breakpoints -->
<div class="p-4 sm:p-6 lg:p-8">
```

## Dark Mode

```html
<div class="bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
```

## States

```html
<!-- Hover, focus, active -->
<button class="hover:bg-blue-700 focus:ring-2 active:bg-blue-800">

<!-- Disabled -->
<button class="disabled:opacity-50 disabled:cursor-not-allowed">

<!-- Group hover -->
<div class="group">
  <span class="group-hover:text-blue-600">
</div>
```

## Animation

```html
<!-- Transitions -->
<div class="transition-all duration-200 ease-in-out">

<!-- Built-in animations -->
<div class="animate-spin">
<div class="animate-pulse">
<div class="animate-bounce">
```

## Best Practices

1. Extract repeated patterns into components or partials
2. Use `@apply` sparingly in CSS files for complex repeated patterns
3. Prefer semantic HTML with utility classes over `<div>` soup
4. Use the official Tailwind CSS IntelliSense extension
5. Customize theme in `tailwind.config.js` rather than arbitrary values
