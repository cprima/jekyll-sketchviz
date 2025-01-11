#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const rough = require('roughjs');
const { JSDOM } = require('jsdom');

function roughifySVG(svgString, options = {}) {
    // Parse the SVG string into a DOM
    const dom = new JSDOM(svgString);
    const svg = dom.window.document.querySelector('svg');

    // Create a Rough.js SVG instance
    const rc = rough.svg(svg, {
        roughness: options.roughness || 1,
        bowing: options.bowing || 1,
    });

    // Process supported elements
    const elements = svg.querySelectorAll('circle, rect, ellipse, line, polygon, polyline, path');
    elements.forEach(element => {
        let shapeType, params;

        switch (element.tagName) {
            case 'circle':
                shapeType = 'circle';
                params = [parseFloat(element.getAttribute('cx')), parseFloat(element.getAttribute('cy')), parseFloat(element.getAttribute('r')) * 2];
                break;
            case 'rect':
                shapeType = 'rectangle';
                params = [parseFloat(element.getAttribute('x')), parseFloat(element.getAttribute('y')), parseFloat(element.getAttribute('width')), parseFloat(element.getAttribute('height'))];
                break;
            case 'ellipse':
                shapeType = 'ellipse';
                params = [parseFloat(element.getAttribute('cx')), parseFloat(element.getAttribute('cy')), parseFloat(element.getAttribute('rx')) * 2, parseFloat(element.getAttribute('ry')) * 2];
                break;
            case 'line':
                shapeType = 'line';
                params = [parseFloat(element.getAttribute('x1')), parseFloat(element.getAttribute('y1')), parseFloat(element.getAttribute('x2')), parseFloat(element.getAttribute('y2'))];
                break;
            case 'polygon':
                shapeType = 'polygon';
                params = [element.getAttribute('points').trim().split(' ').map(point => point.split(',').map(Number))];
                break;
            case 'polyline':
                shapeType = 'linearPath';
                params = [element.getAttribute('points').trim().split(' ').map(point => point.split(',').map(Number))];
                break;
            case 'path':
                shapeType = 'path';
                params = [element.getAttribute('d')];
                break;
            default:
                return;
        }

        // Generate the Rough.js version of the shape
        const sketchyElement = rc[shapeType](...params, {
            stroke: element.getAttribute('stroke') || 'black',
            fill: element.getAttribute('fill') || 'none',
            strokeWidth: parseFloat(element.getAttribute('stroke-width')) || 1,
        });

        // Replace the original element
        element.replaceWith(sketchyElement);
    });

    // Return the modified SVG as a string
    return svg.outerHTML;
}

function roughifyFile(inputPath, options = {}) {
    const svgPath = path.resolve(inputPath);
    const svgContent = fs.readFileSync(svgPath, 'utf-8');
    return roughifySVG(svgContent, options);
}

// Command-line usage
if (require.main === module) {
    const args = process.argv.slice(2);
    if (args.length < 1) {
        console.error('Usage: roughify.js <path-to-svg> [--roughness=<value>] [--bowing=<value>]');
        process.exit(1);
    }

    const inputPath = args[0];
    const options = args.slice(1).reduce((opts, arg) => {
        const [key, value] = arg.split('=');
        if (key === '--roughness') opts.roughness = parseFloat(value);
        if (key === '--bowing') opts.bowing = parseFloat(value);
        return opts;
    }, {});

    console.log(roughifyFile(inputPath, options));
}

module.exports = {
    roughifySVG,
    roughifyFile,
};
