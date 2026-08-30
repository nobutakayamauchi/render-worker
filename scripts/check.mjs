import fs from 'node:fs';

const transitions = JSON.parse(fs.readFileSync('TRANSITIONS.json', 'utf8'));
const html = fs.readFileSync('index.html', 'utf8');
const requiredFields = ['source_image', 'next_image', 'focal_subject_left', 'focal_subject_right', 'dominant_action', 'continuity_target', 'camera_motion', 'transition_type', 'duration', 'easing', 'overlay_timing', 'audio_cue'];
const expected = [1, 2, 3, 4, 5].map(n => `assets/0${n}_${['email_reaction', 'workflow_diverge', 'lunch_contrast', 'afternoon_contrast', 'final_payoff'][n - 1]}.png`);

if (transitions.cuts.length !== 5) throw new Error('TRANSITIONS.json must contain five cuts');
for (const [index, cut] of transitions.cuts.entries()) {
  for (const field of requiredFields) if (!(field in cut)) throw new Error(`cut ${index + 1} missing ${field}`);
  if (cut.source_image !== expected[index]) throw new Error(`unexpected image order at cut ${index + 1}`);
  if (!fs.existsSync(cut.source_image)) throw new Error(`missing ${cut.source_image}`);
  if (!html.includes(cut.source_image)) throw new Error(`${cut.source_image} is not used by index.html`);
}
if (!html.includes('data-duration="15"') || !html.includes('data-width="1080"') || !html.includes('data-height="1920"')) throw new Error('composition metadata mismatch');
console.log('Lightweight checks passed: 5 images, 5 transition plans, 15s, 1080x1920.');
