import { chromium } from 'playwright';
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { spawnSync } from 'node:child_process';

const root = process.cwd();
const frameDir = path.join(root, 'dist', 'frames');
fs.mkdirSync(frameDir, { recursive: true });
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage({ viewport: { width: 1080, height: 1920 }, deviceScaleFactor: 1 });
await page.goto(pathToFileURL(path.join(root, 'index.html')).href);
await page.waitForFunction(() => window.__renderReady === true);

for (let frame = 0; frame < 450; frame++) {
  await page.evaluate(t => window.__seekBridgePatch(t), frame / 30);
  await page.locator('#stage').screenshot({ path: path.join(frameDir, `${String(frame).padStart(4, '0')}.png`) });
}
await browser.close();

const ffmpeg = spawnSync('ffmpeg', [
  '-hide_banner', '-loglevel', 'error', '-y', '-framerate', '30', '-i', path.join(frameDir, '%04d.png'),
  '-i', path.join(root, 'dist', 'bridgepatch_audio.wav'), '-t', '15',
  '-c:v', 'libx264', '-preset', 'medium', '-crf', '18', '-pix_fmt', 'yuv420p',
  '-c:a', 'aac', '-b:a', '192k', '-ar', '48000', '-movflags', '+faststart',
  path.join(root, 'dist', 'bridgepatch_stage2.mp4')
], { stdio: 'inherit' });
if (ffmpeg.status !== 0) process.exit(ffmpeg.status ?? 1);
