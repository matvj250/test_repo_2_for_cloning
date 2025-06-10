#!/usr/bin/env node

/**
 * parse-japicmp.js
 *
 * Reads a plain-text japicmp diff and outputs
 * a JSON report listing each modified class/interface,
 * whether it's compatible, and its added/removed methods and fields.
 *
 * Usage:
 *   node ./parse-japicmp.js \
 *   --input docs/data/japicmp/japicmp-15944.txt \
 *   --output docs/data/japicmp/japicmp-15944.json
 */

const fs = require('fs');
const path = require('path');
const args = process.argv.slice(2);
let inputPath;
let outputPath;

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--input' || args[i] === '-i') {
    inputPath = args[++i];
  } else if (args[i] === '--output' || args[i] === '-o') {
    outputPath = args[++i];
  }
}

if (!inputPath) {
  console.error('Usage: parse-japicmp.js --input <INPUT_PATH> [--output <OUTPUT_PATH>]');
  process.exit(1);
}

if (!fs.existsSync(inputPath)) {
  console.error(`Error: Input file not found: ${inputPath}`);
  process.exit(1);
}

const content = fs.readFileSync(inputPath, 'utf8');
const lines = content.split(/\r?\n/);

const classes = [];
let current = null;

for (const line of lines) {
  // Header: ***! MODIFIED CLASS/INTERFACE: ... (not serializable)
  const headerMatch = line.match(/^\*+!?\s+MODIFIED (?:CLASS|INTERFACE):\s+(.+?)\s+\(/);
  if (headerMatch) {
    const fullNamePart = headerMatch[1].trim();
    const parts = fullNamePart.split(/\s+/);
    const className = parts[parts.length - 1];
    current = {
      className,
      compatible: true,
      removedMethods: [],
      addedMethods: [],
      removedFields: [],
      addedFields: []//,
      // removedClasses: [],
      // addedClasses: []
    };
    classes.push(current);
    continue;
  }
  if (!current) continue;

  let match;
  if (match = line.match(/REMOVED METHOD:\s*(.*)/)) {
    current.removedMethods.push(match[1].trim());
    current.compatible = false;
    continue;
  }
  if (match = line.match(/NEW METHOD:\s*(.*)/)) {
    current.addedMethods.push(match[1].trim());
    continue;
  }
  if (match = line.match(/REMOVED FIELD:\s*(.*)/)) {
    current.removedFields.push(match[1].trim());
    current.compatible = false;
    continue;
  }
  if (match = line.match(/NEW FIELD:\s*(.*)/)) {
    current.addedFields.push(match[1].trim());
    continue;
  }
  // if (match = line.match(/REMOVED CLASS:\s*(.*)/)) {
  //   current.addedFields.push(match[1].trim());
  //   continue;
  // }
  // if (match = line.match(/NEW CLASS:\s*(.*)/)) {
  //   current.addedFields.push(match[1].trim());
  //   continue;
  // }
}

const report = { jcmpClasses: classes };
const outJson = JSON.stringify(report, null, 2);

if (outputPath) {
  const dir = path.dirname(outputPath);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  fs.appendFileSync(outputPath, outJson, 'utf8');
  console.log(`Wrote JSON report to ${outputPath}`);
} else {
  console.log(outJson);
}