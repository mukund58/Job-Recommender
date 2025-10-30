// Minimal HTTP server to accept POST /recommend and return sample recommendations.
// No external dependencies so it's easy to run with `node server/server.js`.
import http from 'http';

const PORT = process.env.PORT || 8000;

function generateRecommendations(skills) {
  // Very small heuristic: return recommendations based on skills provided.
  const recs = [];
  if (!Array.isArray(skills) || skills.length === 0) {
    recs.push('No skills provided — upload a resume with detectable skills.');
    return recs;
  }

  if (skills.includes('javascript') || skills.includes('react') || skills.includes('typescript')) {
    recs.push('Apply to frontend roles (React/JS).');
    recs.push('Build a small portfolio project demonstrating component patterns.');
  }
  if (skills.includes('node')) {
    recs.push('Add a Node backend sample (Express/Koa) to your portfolio.');
  }
  if (skills.includes('python')) {
    recs.push('Explore data engineering or ML internships that use Python.');
  }
  if (recs.length === 0) recs.push('Consider broadening skill examples or adding project links.');
  return recs;
}

const server = http.createServer((req, res) => {
  if (req.method === 'OPTIONS') {
    // Basic CORS handling for non-proxied usage
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    });
    return res.end();
  }

  if (req.method === 'POST' && req.url === '/recommend') {
    let body = '';
    req.on('data', (chunk) => {
      body += chunk;
      // Protect against huge bodies
      if (body.length > 1e6) {
        res.writeHead(413, { 'Content-Type': 'text/plain' });
        res.end('Payload too large');
        req.socket.destroy();
      }
    });
    req.on('end', () => {
      try {
        const payload = JSON.parse(body || '{}');
        const skills = payload.skills || [];
        const recs = generateRecommendations(skills.map(s => String(s).toLowerCase()));
        res.writeHead(200, {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        });
        res.end(JSON.stringify(recs));
      } catch (e) {
        console.error('Error handling /recommend:', e);
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end('Server error');
      }
    });
    return;
  }

  // Not found
  res.writeHead(404, { 'Content-Type': 'text/plain' });
  res.end('Not found');
});

server.listen(PORT, () => {
  console.log(`Recommendation test API listening on http://localhost:${PORT}`);
});
