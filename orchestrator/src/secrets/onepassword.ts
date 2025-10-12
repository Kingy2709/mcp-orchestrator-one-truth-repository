import { createClient, type Client } from '@1password/sdk';
import { config } from '../config';
import { ConfigurationError } from '../utils/errors';
import { logger } from '../utils/logger';

let opClient: Client | null = null;

export async function getOnePasswordClient(): Promise<Client> {
  if (!opClient) {
    try {
      opClient = await createClient({
        auth: config.opServiceAccountToken,
        integrationName: 'MCP Orchestrator',
        integrationVersion: '0.1.0',
      });
      logger.info('1Password client initialized');
    } catch (error) {
      logger.error('Failed to initialize 1Password client', { error });
      throw new ConfigurationError('1Password initialization failed', error);
    }
  }
  return opClient;
}

export async function getSecret(reference: string): Promise<string> {
  try {
    const client = await getOnePasswordClient();
    const secret = await client.secrets.resolve(reference);

    logger.debug('Secret retrieved', { reference: reference.replace(/[^:\/]/g, '*') });
    return secret;
  } catch (error) {
    logger.error('Failed to retrieve secret', { error, reference });
    throw new ConfigurationError(`Failed to get secret: ${reference}`, error);
  }
}

export async function listVaults(): Promise<string[]> {
  try {
    const client = await getOnePasswordClient();
    // TODO: Implement vault listing if SDK supports it
    // For now, return empty array
    return [];
  } catch (error) {
    logger.error('Failed to list vaults', { error });
    return [];
  }
}
