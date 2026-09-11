BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  email CITEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role VARCHAR(10) NOT NULL DEFAULT 'USER' CHECK (role IN ('USER', 'ADMIN')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS papers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  university VARCHAR(200) NOT NULL,
  department VARCHAR(150) NOT NULL,
  course VARCHAR(150) NOT NULL,
  semester SMALLINT NOT NULL CHECK (semester > 0 AND semester <= 20),
  subject VARCHAR(200) NOT NULL,
  subject_code VARCHAR(100),
  year SMALLINT NOT NULL CHECK (year BETWEEN 1900 AND 2100),
  exam_type VARCHAR(100) NOT NULL,
  paper_code VARCHAR(100),
  file_hash CHAR(64) NOT NULL UNIQUE,
  storage_key TEXT NOT NULL UNIQUE,
  file_size BIGINT NOT NULL CHECK (file_size > 0),
  uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  status VARCHAR(10) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
  download_count INTEGER NOT NULL DEFAULT 0 CHECK (download_count >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  paper_id UUID NOT NULL REFERENCES papers(id) ON DELETE CASCADE,
  reported_by UUID REFERENCES users(id) ON DELETE SET NULL,
  reason VARCHAR(30) NOT NULL CHECK (reason IN ('DUPLICATE', 'WRONG_INFORMATION', 'WRONG_PAPER', 'COPYRIGHT', 'OTHER')),
  details TEXT,
  status VARCHAR(12) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'RESOLVED', 'DISMISSED')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS papers_browse_idx
  ON papers (university, course, department, semester, subject, year, exam_type)
  WHERE status = 'APPROVED';
CREATE INDEX IF NOT EXISTS papers_status_created_at_idx ON papers (status, created_at DESC);
CREATE INDEX IF NOT EXISTS papers_uploaded_by_idx ON papers (uploaded_by, created_at DESC);
CREATE INDEX IF NOT EXISTS reports_status_created_at_idx ON reports (status, created_at ASC);
CREATE INDEX IF NOT EXISTS reports_paper_id_idx ON reports (paper_id);

COMMIT;
