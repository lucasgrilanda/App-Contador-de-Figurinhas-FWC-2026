// Netlify Function — proxy para Gemini 1.5 Flash
// A chave fica APENAS na env var GEMINI_API_KEY no painel do Netlify
exports.handler = async (event) => {
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  if (event.httpMethod === 'OPTIONS') return { statusCode: 200, headers, body: '' };
  if (event.httpMethod !== 'POST') return { statusCode: 405, headers, body: JSON.stringify({ error: 'Method not allowed' }) };

  try {
    const { image } = JSON.parse(event.body);
    const apiKey = process.env.GEMINI_API_KEY;

    if (!apiKey) return { statusCode: 500, headers, body: JSON.stringify({ error: 'GEMINI_API_KEY não configurada' }) };
    if (!image)  return { statusCode: 400, headers, body: JSON.stringify({ error: 'Campo image ausente' }) };

    const res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [
            {
              text: 'Esta é uma foto de uma figurinha da Copa do Mundo 2026 Panini. Encontre o código identificador da figurinha. O código tem exatamente este formato: 2 ou 3 letras maiúsculas seguidas de 1 ou 2 dígitos. Exemplos válidos: BRA17, MEX14, FWC5, CC12, RSA3, ARG10, POR15. O código costuma aparecer em algum canto da figurinha como texto pequeno impresso. Responda SOMENTE com o código em letras maiúsculas, sem espaço, sem ponto, sem explicação. Se não conseguir identificar claramente um código válido, responda apenas: null'
            },
            { inline_data: { mime_type: 'image/jpeg', data: image } }
          ]}],
          generationConfig: { temperature: 0, maxOutputTokens: 10 }
        })
      }
    );

    const data = await res.json();

    if (!res.ok) {
      return { statusCode: 502, headers, body: JSON.stringify({ error: 'Gemini error', detail: data.error?.message }) };
    }

    const raw = (data.candidates?.[0]?.content?.parts?.[0]?.text || '').trim().toUpperCase().replace(/\s/g, '');

    // Validação no servidor: formato correto
    const valid = /^(FWC([1-9]|1[0-9])|CC([1-9]|1[0-4])|00|[A-Z]{2,3}([1-9]|[12]\d))$/.test(raw);
    const code = valid ? raw : null;

    return { statusCode: 200, headers, body: JSON.stringify({ code, raw }) };

  } catch (e) {
    return { statusCode: 500, headers, body: JSON.stringify({ error: e.message }) };
  }
};
