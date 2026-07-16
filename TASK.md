## Prompt: Rework the Date Picker UI/UX

Let's completely redesign and optimize the date picker experience across the application.

The current date picker feels bulky, visually inconsistent, and does not follow modern Material Design principles. Its spacing, hierarchy, interaction flow, and overall appearance make it feel disconnected from the rest of the application's UI. The goal is to replace it with a cleaner, native-feeling, Material Design date picker that provides a fast and intuitive user experience while remaining consistent with our project's design system.

### Objective

Implement a modern Material Design date picker that:

* Feels lightweight and native.
* Matches our application's theme, typography, colors, spacing, border radius, and elevation.
* Provides a clean, predictable, and accessible user experience.
* Is reusable throughout the project from a single component.

### Reference

I have attached a reference image.

**Important:**

* The image is **only for UI/UX inspiration**.
* **Do not copy it exactly.**
* Analyze its layout, spacing, typography, hierarchy, navigation, and interaction patterns.
* Recreate the experience while following **our project's existing design language and theme**.

### UI/UX Improvements

#### Overall Design

* Replace the current bulky dialog with a compact Material-style calendar.
* Maintain proper padding and whitespace.
* Improve visual hierarchy.
* Use subtle elevation and rounded corners.
* Remove unnecessary visual clutter.

#### Header

* Clean month and year display.
* Easy previous/next month navigation.
* Clear indication of the currently displayed month.
* Smooth month switching animation if supported.

#### Calendar Grid

* Equal spacing between dates.
* Consistent alignment.
* Today's date should have a subtle indicator.
* Selected date should use the project's primary color.
* Disabled dates should be visually distinguishable.
* Hover, focus, and pressed states should feel responsive.

#### Typography

* Use the project's typography scale.
* Improve readability.
* Proper font weights for:

  * Month
  * Year
  * Weekday labels
  * Date numbers

#### Theme Integration

The date picker should automatically support:

* Light Theme
* Dark Theme

using our existing color palette without introducing new design patterns.

#### Interactions

* Single tap to select a date.
* Clear selected state.
* Immediate visual feedback.
* Proper keyboard navigation (where applicable).
* Accessible focus states.

#### Performance

* Keep the widget lightweight.
* Avoid unnecessary rebuilds.
* Optimize rendering.
* Ensure smooth scrolling and month transitions.

### Functional Requirements

The new date picker must support:

* Single date selection
* Minimum date
* Maximum date
* Initial selected date
* Current date highlight
* Cancel action
* Confirm/Done action
* Proper validation
* Localization support
* Future extensibility for date range selection

### Reusability

Create a reusable component that can be used throughout the application.

The API should remain simple and configurable without duplicating code across screens.

### Responsive Behavior

Ensure the date picker works correctly on:

* Small phones
* Large phones
* Tablets
* Landscape orientation

### Accessibility

Follow Material accessibility guidelines:

* Proper touch targets (minimum 48dp)
* High contrast
* Screen reader compatibility
* Keyboard accessibility
* Semantic labels where applicable

### Code Quality

* Follow the existing project architecture.
* Keep the implementation modular.
* Avoid hardcoded values.
* Centralize dimensions, colors, and typography.
* Write clean, maintainable, and reusable code.

### Expected Result

The final date picker should feel like a polished, native Material component that integrates seamlessly into our application. It should provide a significantly better user experience than the current implementation while maintaining consistency with our overall UI/UX and project theme. The attached image should serve only as inspiration for layout and interaction patterns, not as a direct visual copy.
