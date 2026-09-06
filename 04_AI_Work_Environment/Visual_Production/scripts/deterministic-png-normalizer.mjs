#!/usr/bin/env node
import { promises as fs } from 'node:fs';
import { deflateSync, inflateSync, constants as zlibConstants } from 'node:zlib';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

export const NORMALIZER_TOOL = 'repository-node-png-normalizer';
export const NORMALIZER_VERSION = '1.0.0';
export const NORMALIZER_METHOD = 'center-crop-cover-fixedpoint-bilinear-rgba8-png';
export const PNG_ENCODING = 'rgba8-filter-none-zlib-fixed-level9';

const PNG_SIGNATURE = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
const CHANNELS = new Map([[0, 1], [2, 3], [4, 2], [6, 4]]);

function fail(code, detail = '') { throw new Error(`${code}${detail ? `: ${detail}` : ''}`); }
function requireValue(condition, code, detail = '') { if (!condition) fail(code, detail); }

const CRC_TABLE = (() => {
  const table = new Uint32Array(256);
  for (let n = 0; n < 256; n += 1) {
    let value = n;
    for (let k = 0; k < 8; k += 1) value = (value & 1) ? (0xedb88320 ^ (value >>> 1)) : (value >>> 1);
    table[n] = value >>> 0;
  }
  return table;
})();

function crc32(buffer) {
  let crc = 0xffffffff;
  for (const byte of buffer) crc = CRC_TABLE[(crc ^ byte) & 0xff] ^ (crc >>> 8);
  return (crc ^ 0xffffffff) >>> 0;
}

function pngChunk(type, data) {
  const typeBytes = Buffer.from(type, 'ascii');
  const chunk = Buffer.alloc(12 + data.length);
  chunk.writeUInt32BE(data.length, 0);
  typeBytes.copy(chunk, 4);
  data.copy(chunk, 8);
  chunk.writeUInt32BE(crc32(Buffer.concat([typeBytes, data])), 8 + data.length);
  return chunk;
}

function paeth(a, b, c) {
  const p = a + b - c;
  const pa = Math.abs(p - a);
  const pb = Math.abs(p - b);
  const pc = Math.abs(p - c);
  if (pa <= pb && pa <= pc) return a;
  return pb <= pc ? b : c;
}

export function decodePng(buffer) {
  requireValue(Buffer.isBuffer(buffer) && buffer.length >= 33 && buffer.subarray(0, 8).equals(PNG_SIGNATURE), 'PNG_NORMALIZATION_INPUT_INVALID');
  let offset = 8;
  let ihdr;
  const idat = [];
  let sawEnd = false;
  while (offset + 12 <= buffer.length) {
    const length = buffer.readUInt32BE(offset);
    const end = offset + 12 + length;
    requireValue(end <= buffer.length, 'PNG_NORMALIZATION_CHUNK_TRUNCATED');
    const typeBytes = buffer.subarray(offset + 4, offset + 8);
    const type = typeBytes.toString('ascii');
    const data = buffer.subarray(offset + 8, offset + 8 + length);
    requireValue(buffer.readUInt32BE(offset + 8 + length) === crc32(Buffer.concat([typeBytes, data])), 'PNG_NORMALIZATION_CRC_MISMATCH', type);
    if (type === 'IHDR') ihdr = Buffer.from(data);
    else if (type === 'IDAT') idat.push(Buffer.from(data));
    else if (type === 'IEND') { sawEnd = true; break; }
    offset = end;
  }
  requireValue(ihdr?.length === 13 && idat.length && sawEnd, 'PNG_NORMALIZATION_STRUCTURE_INVALID');
  const width = ihdr.readUInt32BE(0);
  const height = ihdr.readUInt32BE(4);
  const bitDepth = ihdr[8];
  const colorType = ihdr[9];
  requireValue(width > 0 && height > 0 && bitDepth === 8 && CHANNELS.has(colorType), 'PNG_NORMALIZATION_FORMAT_UNSUPPORTED', `bit_depth=${bitDepth} color_type=${colorType}`);
  requireValue(ihdr[10] === 0 && ihdr[11] === 0 && ihdr[12] === 0, 'PNG_NORMALIZATION_FORMAT_UNSUPPORTED', 'compression/filter/interlace');
  const channels = CHANNELS.get(colorType);
  const stride = width * channels;
  let inflated;
  try { inflated = inflateSync(Buffer.concat(idat)); }
  catch (error) { fail('PNG_NORMALIZATION_INFLATE_FAIL', error.message); }
  requireValue(inflated.length === height * (stride + 1), 'PNG_NORMALIZATION_SCANLINE_SIZE_MISMATCH');
  const decoded = Buffer.alloc(width * height * channels);
  for (let y = 0; y < height; y += 1) {
    const inputRow = y * (stride + 1);
    const outputRow = y * stride;
    const filter = inflated[inputRow];
    requireValue(filter <= 4, 'PNG_NORMALIZATION_FILTER_UNSUPPORTED', String(filter));
    for (let x = 0; x < stride; x += 1) {
      const raw = inflated[inputRow + 1 + x];
      const left = x >= channels ? decoded[outputRow + x - channels] : 0;
      const up = y > 0 ? decoded[outputRow - stride + x] : 0;
      const upperLeft = y > 0 && x >= channels ? decoded[outputRow - stride + x - channels] : 0;
      const predictor = filter === 0 ? 0 : filter === 1 ? left : filter === 2 ? up : filter === 3 ? Math.floor((left + up) / 2) : paeth(left, up, upperLeft);
      decoded[outputRow + x] = (raw + predictor) & 0xff;
    }
  }
  const rgba = Buffer.alloc(width * height * 4);
  for (let pixel = 0; pixel < width * height; pixel += 1) {
    const source = pixel * channels;
    const target = pixel * 4;
    if (colorType === 0) {
      rgba[target] = decoded[source]; rgba[target + 1] = decoded[source]; rgba[target + 2] = decoded[source]; rgba[target + 3] = 255;
    } else if (colorType === 2) {
      rgba[target] = decoded[source]; rgba[target + 1] = decoded[source + 1]; rgba[target + 2] = decoded[source + 2]; rgba[target + 3] = 255;
    } else if (colorType === 4) {
      rgba[target] = decoded[source]; rgba[target + 1] = decoded[source]; rgba[target + 2] = decoded[source]; rgba[target + 3] = decoded[source + 1];
    } else {
      decoded.copy(rgba, target, source, source + 4);
    }
  }
  return { width, height, rgba };
}

export function encodeRgbaPng({ width, height, rgba }) {
  requireValue(Number.isInteger(width) && width > 0 && Number.isInteger(height) && height > 0, 'PNG_NORMALIZATION_OUTPUT_DIMENSIONS_INVALID');
  requireValue(Buffer.isBuffer(rgba) && rgba.length === width * height * 4, 'PNG_NORMALIZATION_RGBA_SIZE_MISMATCH');
  const scanlines = Buffer.alloc(height * (width * 4 + 1));
  for (let y = 0; y < height; y += 1) rgba.copy(scanlines, y * (width * 4 + 1) + 1, y * width * 4, (y + 1) * width * 4);
  const header = Buffer.alloc(13);
  header.writeUInt32BE(width, 0); header.writeUInt32BE(height, 4);
  header[8] = 8; header[9] = 6; header[10] = 0; header[11] = 0; header[12] = 0;
  const compressed = deflateSync(scanlines, { level: 9, strategy: zlibConstants.Z_FIXED, memLevel: 9 });
  return Buffer.concat([PNG_SIGNATURE, pngChunk('IHDR', header), pngChunk('IDAT', compressed), pngChunk('IEND', Buffer.alloc(0))]);
}

function axisCoordinate(index, sourceSize, targetSize, offset) {
  const numerator = BigInt((2 * index + 1) * sourceSize) * 65536n;
  const fixed = numerator / BigInt(2 * targetSize) - 32768n + BigInt(offset) * 65536n;
  const minimum = BigInt(offset) * 65536n;
  const maximum = BigInt(offset + sourceSize - 1) * 65536n;
  const clamped = fixed < minimum ? minimum : fixed > maximum ? maximum : fixed;
  const base = Number(clamped / 65536n);
  return { base, fraction: Number(clamped % 65536n) };
}

export function resizeCoverFixedPoint(source, targetWidth = 1280, targetHeight = 670) {
  const sourceWidth = source.width;
  const sourceHeight = source.height;
  let cropWidth = sourceWidth;
  let cropHeight = sourceHeight;
  if (sourceWidth * targetHeight > sourceHeight * targetWidth) cropWidth = Math.floor((sourceHeight * targetWidth + Math.floor(targetHeight / 2)) / targetHeight);
  else if (sourceWidth * targetHeight < sourceHeight * targetWidth) cropHeight = Math.floor((sourceWidth * targetHeight + Math.floor(targetWidth / 2)) / targetWidth);
  cropWidth = Math.max(1, Math.min(sourceWidth, cropWidth));
  cropHeight = Math.max(1, Math.min(sourceHeight, cropHeight));
  const cropX = Math.floor((sourceWidth - cropWidth) / 2);
  const cropY = Math.floor((sourceHeight - cropHeight) / 2);
  const xMap = Array.from({ length: targetWidth }, (_, x) => axisCoordinate(x, cropWidth, targetWidth, cropX));
  const yMap = Array.from({ length: targetHeight }, (_, y) => axisCoordinate(y, cropHeight, targetHeight, cropY));
  const output = Buffer.alloc(targetWidth * targetHeight * 4);
  for (let y = 0; y < targetHeight; y += 1) {
    const y0 = yMap[y].base;
    const y1 = Math.min(cropY + cropHeight - 1, y0 + 1);
    const fy = yMap[y].fraction;
    for (let x = 0; x < targetWidth; x += 1) {
      const x0 = xMap[x].base;
      const x1 = Math.min(cropX + cropWidth - 1, x0 + 1);
      const fx = xMap[x].fraction;
      const destination = (y * targetWidth + x) * 4;
      for (let channel = 0; channel < 4; channel += 1) {
        const p00 = source.rgba[(y0 * sourceWidth + x0) * 4 + channel];
        const p10 = source.rgba[(y0 * sourceWidth + x1) * 4 + channel];
        const p01 = source.rgba[(y1 * sourceWidth + x0) * 4 + channel];
        const p11 = source.rgba[(y1 * sourceWidth + x1) * 4 + channel];
        const top = p00 * (65536 - fx) + p10 * fx;
        const bottom = p01 * (65536 - fx) + p11 * fx;
        output[destination + channel] = Math.floor((top * (65536 - fy) + bottom * fy + 2147483648) / 4294967296);
      }
    }
  }
  return { width: targetWidth, height: targetHeight, rgba: output, crop: { x: cropX, y: cropY, width: cropWidth, height: cropHeight } };
}

export async function normalizePng({ inputPath, outputPath, targetWidth = 1280, targetHeight = 670 }) {
  const input = await fs.readFile(inputPath);
  const decoded = decodePng(input);
  const normalized = resizeCoverFixedPoint(decoded, targetWidth, targetHeight);
  const encoded = encodeRgbaPng(normalized);
  try {
    const existing = await fs.readFile(outputPath);
    requireValue(existing.equals(encoded), 'PNG_NORMALIZATION_IMMUTABLE_CONFLICT');
  } catch (error) {
    if (error.code === 'ENOENT') await fs.writeFile(outputPath, encoded);
    else throw error;
  }
  return {
    input: { width: decoded.width, height: decoded.height },
    output: { width: targetWidth, height: targetHeight },
    crop: normalized.crop,
    transform: { tool: NORMALIZER_TOOL, version: NORMALIZER_VERSION, method: NORMALIZER_METHOD, encoding: PNG_ENCODING }
  };
}

function parseArgs(argv) {
  const result = { _: [] };
  for (let index = 0; index < argv.length; index += 1) {
    const item = argv[index];
    if (!item.startsWith('--')) result._.push(item);
    else { const value = argv[index + 1]; requireValue(value && !value.startsWith('--'), 'PNG_NORMALIZATION_ARGUMENT_REQUIRED', item); result[item.slice(2)] = value; index += 1; }
  }
  return result;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  requireValue(args._[0] === 'verify', 'PNG_NORMALIZATION_USAGE', 'verify --input <raw.png> --output <normalized.png> --crop-x <n> --crop-y <n> --crop-width <n> --crop-height <n>');
  const source = decodePng(await fs.readFile(path.resolve(args.input)));
  const normalized = resizeCoverFixedPoint(source, 1280, 670);
  const expected = encodeRgbaPng(normalized);
  const actual = await fs.readFile(path.resolve(args.output));
  requireValue(actual.equals(expected), 'PNG_NORMALIZATION_DETERMINISTIC_OUTPUT_MISMATCH');
  const expectedCrop = { x: Number(args['crop-x']), y: Number(args['crop-y']), width: Number(args['crop-width']), height: Number(args['crop-height']) };
  requireValue(Object.values(expectedCrop).every(Number.isInteger) && JSON.stringify(expectedCrop) === JSON.stringify(normalized.crop), 'PNG_NORMALIZATION_CROP_MISMATCH');
  console.log(JSON.stringify({ result: 'PASS', dimensions: { width: 1280, height: 670 }, crop: normalized.crop }));
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main().catch((error) => { console.error(error.message); process.exitCode = 1; });
