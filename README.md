# Jekyll SketchViz Plugin

`jekyll-sketchviz` is a Jekyll plugin that transforms Graphviz `.dot` files into beautifully "roughened" SVG diagrams using [Rough.js](https://roughjs.com/). The plugin supports two output formats: inline SVGs for web pages and unstyled SVG files for filesystem output, enabling seamless integration into your Jekyll site.

---

## Features

- **Graphviz `.dot` File Support**:
  - Converts `.dot` files into SVG using the `dot` executable.
- **Rough.js Integration**:
  - Adds sketch-style effects to `rect`, `circle`, `ellipse`, `line`, `polygon`, `polyline`, and `path` elements.
- **Output Formats**:
  - **Inline SVGs**: Styled via CSS for webpage inclusion.
  - **Filesystem SVGs**: Unstyled, inheriting Graphviz defaults, ideal for printed or static usage.
- **Customizable Settings**:
  - Configure Rough.js parameters (`roughness`, `bowing`), output directories, and CSS class mappings.
- **Flexible Liquid Tag API**:
  - Include diagrams inline or as files with per-use overrides.
- **Theme-Agnostic Styling**:
  - Inline SVGs styled using global or diagram-specific CSS.

---

## Installation

1. Add the plugin to your Gemfile:
   ```ruby
   gem "jekyll-sketchviz"
   ```

2. Run `bundle install`.

3. Add the plugin to your `_config.yml`:
   ```yaml
   plugins:
     - jekyll-sketchviz
   ```

4. Configure the plugin (optional):
   ```yaml
   sketchviz:
     input_collection: graphs
     output:
       filesystem:
         directory: assets/graphs
         styled: false
       inline:
         styled: true
         css_classes:
           svg: sketchviz
           background: sketchviz-bg
           node: sketchviz-node
           edge: sketchviz-edge
     executable:
       dot: dot
     roughness: 1.5
     bowing: 1.0
   ```

---

## Usage

### 1. **Add `.dot` Files**
Place `.dot` files in your Jekyll collection (e.g., `_graphs/`).

### 2. **Include Diagrams with Liquid Tag**
Use the `{% sketchviz %}` tag in your Markdown or HTML:

**Basic Usage**:
```liquid
{% sketchviz "diagram.dot" %}
```

**Advanced Usage**:
```liquid
{% sketchviz "subdir/diagram.dot", inline: true, roughness: 2.5, styled: true %}
```

---

## Configuration

### Global Configuration
Configure global defaults in `_config.yml`:

```yaml
sketchviz:
  input_collection: graphs
  output:
    filesystem:
      directory: assets/graphs
      styled: false
    inline:
      styled: true
      css_classes:
        svg: sketchviz
        background: sketchviz-bg
        node: sketchviz-node
        edge: sketchviz-edge
  executable:
    dot: dot
  roughness: 1.5
  bowing: 1.0
```

### Per-File Configuration
Override settings in `.dot` file front matter:
```yaml
---
title: Custom Diagram
sketchviz:
  roughness: 2.0
  bowing: 1.5
  styled: true
---
```

---

## Examples

### **Inline SVG**
Rendered directly in your page:
```html
<svg class="sketchviz">
  <!-- Rough.js transformations applied -->
</svg>
```

### **Filesystem SVG**
Referenced in your content:
```markdown
![Diagram](assets/graphs/diagram.svg)
```

---

## Requirements

- **Graphviz**: `dot` executable must be available in your system's PATH or configured explicitly.
- **Rough.js**: Included as part of the plugin.

---

## Contributing

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature-name`.
3. Commit your changes: `git commit -m 'Add feature'`.
4. Push to the branch: `git push origin feature-name`.
5. Open a pull request.

---

## License

This project is licensed under the CC-BY License. See the `LICENSE.md` file for details.