import "dotenv/config";
import { Pool } from "pg";

const databaseUrl = process.env.DATABASE_URL;

export const pool = new Pool(
  databaseUrl
    ? {
        connectionString: databaseUrl,
        ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : undefined,
      }
    : undefined,
);

pool.options.connectionTimeoutMillis = Number(process.env.DB_CONNECTION_TIMEOUT_MS) || 5_000;

export async function checkDatabaseConnection(): Promise<void> {
  await pool.query("SELECT 1");
}
