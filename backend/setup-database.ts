import "dotenv/config";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { pool } from "./database";

async function setupDatabase(): Promise<void> {
  if (!process.env.DATABASE_URL) {
    throw new Error("DATABASE_URL is required. Copy .env.example to .env and set it first.");
  }

  const schemaPath = path.resolve(process.cwd(), "../database/schema.sql");
  const schema = await readFile(schemaPath, "utf8");
  await pool.query(schema);
  console.log("Database schema applied successfully.");
}

setupDatabase()
  .catch((error: unknown) => {
    console.error(error instanceof Error ? error.message : error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await pool.end();
  });
