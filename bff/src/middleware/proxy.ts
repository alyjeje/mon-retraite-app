/**
 * Proxy middleware: forward les requetes du BFF vers l'upstream (mock ou Groupama reel).
 * Gere le token JWT Groupama, les erreurs, les timeouts.
 */
import { Request, Response } from 'express';
import { config } from '../config';

interface ProxyOptions {
  method?: string;
  path: string;
  body?: any;
  token?: string;
  query?: Record<string, string>;
}

export async function proxyToUpstream(options: ProxyOptions): Promise<{ status: number; data: any }> {
  const { method = 'GET', path, body, token, query } = options;

  // Concatener baseUrl + path (ne pas utiliser new URL qui ecrase le basePath)
  const baseUrl = config.upstream.baseUrl.replace(/\/$/, '');
  let fullUrl = `${baseUrl}${path}`;

  if (query) {
    const params = new URLSearchParams(query);
    fullUrl += `?${params.toString()}`;
  }

  const url = fullUrl;

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const fetchOptions: RequestInit = {
    method,
    headers,
  };

  if (body && method !== 'GET') {
    fetchOptions.body = JSON.stringify(body);
  }

  const response = await fetch(url, fetchOptions);
  const contentType = response.headers.get('content-type') || '';

  let data: any;
  if (contentType.includes('application/json')) {
    data = await response.json();
  } else {
    data = await response.text();
  }

  return { status: response.status, data };
}

/**
 * Helper: extrait le token de la session BFF (stocke dans req)
 */
export function getUpstreamToken(req: Request): string | undefined {
  return (req as any).upstreamToken;
}
