# question-paper-hub
A centralized university question paper repository where students can upload, search, view, and download verified question papers with structured metadata, duplicate detection, cloud storage, and admin moderation.


Bilkul. Is project ko main **3 phases** mein build karunga: pehle simple MVP, phir security/moderation, phir advanced features. Isse tum unnecessary complexity se bachoge.

# 1. Overall Architecture

```text
                         ┌──────────────────────┐
                         │       USER           │
                         │ Student / Admin      │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │      FRONTEND        │
                         │      Next.js         │
                         └──────────┬───────────┘
                                    │
                              REST API / HTTPS
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │       BACKEND        │
                         │ Node.js + Express    │
                         └───────┬───────┬──────┘
                                 │       │
                    ┌────────────┘       └─────────────┐
                    ▼                                  ▼
          ┌──────────────────┐              ┌──────────────────┐
          │    PostgreSQL    │              │  Object Storage  │
          │                  │              │                  │
          │ User             │              │ Actual PDF files │
          │ Paper metadata   │              │                  │
          │ Reports          │              │ Cloudflare R2    │
          └──────────────────┘              └──────────────────┘
```

### Simple rule

**PostgreSQL → information about paper**

**R2 → actual PDF**

---

# 2. Tech Stack

Since tum MERN/Next.js side pe ho, main ye stack recommend karunga:

### Frontend

**Next.js + TypeScript**

### Backend

Either:

**Next.js API Routes**

or, if you want proper backend separation:

**Node.js + Express**

For learning + portfolio, I'd choose:

```text
Next.js
   +
Node.js/Express
   +
PostgreSQL
   +
Cloudflare R2
```

### Authentication

Initially:

* Email/password
* Google login optional
* JWT/session-based authentication

### Database

**PostgreSQL**

### File Storage

**Cloudflare R2**

### Deployment

```text
Frontend → Vercel
Backend → Render / Railway / similar
Database → Supabase/Neon/PostgreSQL provider
Files → Cloudflare R2
```

You don't have to deploy everything separately during development.

---

# 3. Phase 1 — Requirements

Sabse pehle decide karo ki paper ke saath kya information store karni hai.

### Paper metadata

```text
University
Department
Course
Semester
Subject
Subject Code
Year
Exam Type
Paper Code
Uploaded By
Upload Date
File Size
File Hash
Storage Key
Status
Download Count
```

Example:

```text
University: PES University
Course: MCA
Semester: 2
Subject: Java Programming
Year: 2026
Exam Type: End Semester
```

---

# 4. Phase 2 — Database Design

Basic tables:

```text
users
   │
   └──── uploads ──── papers
                         │
                         ├── university
                         ├── department
                         ├── subject
                         ├── semester
                         ├── year
                         ├── exam_type
                         ├── file_hash
                         └── storage_key
```

You can start with:

### `users`

```text
id
name
email
password_hash
role
created_at
```

### `papers`

```text
id
university
department
course
semester
subject
subject_code
year
exam_type
file_hash
storage_key
file_size
uploaded_by
status
download_count
created_at
```

### `reports`

```text
id
paper_id
reported_by
reason
status
created_at
```

Later database normalization kar sakte ho.

---

# 5. Phase 3 — Authentication

Do roles:

```text
USER
ADMIN
```

### Normal user

Can:

```text
Register
Login
Search
View
Download
Upload
See own uploads
```

### Admin

Can:

```text
View uploads
Approve
Reject
Delete
Handle reports
Manage users
```

---

# 6. Phase 4 — Upload System

Ye project ka **most important flow** hai.

User:

```text
Upload Paper
      ↓
Fill Form
      ↓
Select PDF
      ↓
Submit
```

Backend:

```text
Receive PDF
      ↓
Check file type
      ↓
Check file size
      ↓
Generate SHA-256 hash
      ↓
Check duplicate
      ↓
Upload to R2
      ↓
Save metadata in PostgreSQL
      ↓
Status = Pending
```

---

# 7. Duplicate Detection

Tumne jo decide kiya hai, wahi implement karenge.

```text
                PDF
                 ↓
             SHA-256
                 ↓
       ┌─────────┴─────────┐
       │                   │
   Hash exists?          New hash
       │                   │
      YES                  NO
       ↓                   ↓
   Reject              Upload R2
                           ↓
                       Save DB
```

Important:

**Filename compare nahi karna.**

`java.pdf` aur `final_java.pdf` same PDF ho sakte hain.

Hash compare karna hai.

---

# 8. File Naming

User filename decide nahi karega.

Backend automatically unique storage key generate karega.

Example:

```text
papers/
  pes/
    mca/
      semester-2/
        java/
          2026/
            8a72f91c.pdf
```

UI par however friendly name show kar sakte ho:

> MCA Sem 2 Java — End Semester 2026

---

# 9. Moderation System

Upload ke baad directly public karne ke bajaye:

```text
PENDING
   ↓
ADMIN REVIEW
   ↓
 ┌─────────┐
 ↓         ↓
APPROVED  REJECTED
 ↓
PUBLIC
```

Admin dashboard:

```text
┌─────────────────────────────────┐
│ Pending Papers                  │
├─────────────────────────────────┤
│ Java | MCA | 2026 | [Review]   │
│ DBMS | MCA | 2025 | [Review]   │
└─────────────────────────────────┘
```

---

# 10. Search System

Ye website ka main attraction hoga.

User ko filters do:

```text
University
Course
Department
Semester
Subject
Year
Exam Type
```

Example:

```text
MCA
Semester 2
Java
2026
End Semester
```

Result:

```text
Java Programming
MCA • Semester 2 • 2026
End Semester

[View PDF] [Download]
```

---

# 11. Download Architecture

Direct public storage access avoid karo.

Better:

```text
User clicks Download
        ↓
Backend
        ↓
Check paper exists
        ↓
Check status = APPROVED
        ↓
Generate temporary signed URL
        ↓
R2
        ↓
PDF download
```

Isse tum R2 bucket ko unnecessarily public nahi karte.

---

# 12. Report System

Har paper ke saath:

```text
⚠ Report Paper
```

Reasons:

```text
Duplicate
Wrong Information
Wrong Question Paper
Copyright Issue
Other
```

Admin:

```text
Report
   ↓
Review
   ↓
Take Action
```

---

# 13. Admin Dashboard

Admin ke liye separate dashboard:

```text
             ADMIN DASHBOARD

Users                  2,431
Papers                 8,932
Pending                37
Reports                12
Downloads              84,291
```

Sections:

```text
├── Dashboard
├── Papers
├── Pending Uploads
├── Reports
├── Users
└── Settings
```

---

# 14. Phase 5 — Security

Basic security must-have:

### Upload

```text
PDF only
Maximum file size
MIME validation
File signature validation
Hash checking
```

### Authentication

```text
Password hashing
Session/JWT
Role-based authorization
```

### API

```text
Rate limiting
Input validation
SQL injection protection
CORS configuration
```

### Storage

```text
Private bucket
Signed URLs
No storage credentials in frontend
```

---

# 15. Phase 6 — UI

Pages roughly:

```text
/
│
├── /search
│
├── /paper/[id]
│
├── /upload
│
├── /login
│
├── /register
│
├── /my-uploads
│
└── /admin
      ├── dashboard
      ├── papers
      ├── pending
      ├── reports
      └── users
```

Homepage simple rakho:

```text
┌─────────────────────────────────────────┐
│ QuestionPaperHub          Login Upload  │
├─────────────────────────────────────────┤
│                                         │
│       Find Your University Papers       │
│                                         │
│    [ Search subject, paper, year... ]   │
│                                         │
│       [ Search ]                        │
│                                         │
├─────────────────────────────────────────┤
│ Popular Subjects                        │
│ Java | DBMS | OS | Networks | AI/ML    │
└─────────────────────────────────────────┘
```

---

# 16. Development Order

**Is order mein banana.**

### Stage 1 — Foundation

```text
1. Create GitHub repository
2. Create Next.js project
3. Setup PostgreSQL
4. Design database
5. Setup backend
```

### Stage 2 — Authentication

```text
6. Register
7. Login
8. Logout
9. User roles
10. Protected routes
```

### Stage 3 — Paper Management

```text
11. Upload form
12. PDF validation
13. Hash generation
14. Duplicate detection
15. R2 upload
16. Save metadata
```

### Stage 4 — Search

```text
17. Paper listing
18. Search
19. Filters
20. Paper details
21. PDF viewing
22. Download
```

### Stage 5 — Admin

```text
23. Admin dashboard
24. Pending papers
25. Approve/reject
26. Delete paper
27. Reports
28. User management
```

### Stage 6 — Security

```text
29. Rate limiting
30. Input validation
31. Storage security
32. Signed URLs
33. Upload restrictions
```

### Stage 7 — Deployment

```text
34. Deploy frontend
35. Deploy backend
36. Setup production DB
37. Setup R2
38. Environment variables
39. Domain
40. Testing
```

---

# 17. MVP mein kya-kya hona chahiye?

**First version mein over-engineer mat karna.**

Bas:

```text
✅ Register/Login
✅ Upload PDF
✅ Metadata form
✅ Duplicate detection
✅ Cloud storage
✅ Database
✅ Search/filter
✅ View PDF
✅ Download
✅ Admin approval
```

Ye complete MVP hai.

### Later features

```text
🔵 OCR
🔵 AI metadata extraction
🔵 Advanced search
🔵 Recommendations
🔵 Most downloaded papers
🔵 Email notifications
🔵 University-wise analytics
🔵 PWA/mobile support
```

---

## Final Architecture

```text
                       INTERNET
                           │
                           ▼
                 ┌───────────────────┐
                 │     Next.js       │
                 │    Frontend       │
                 └─────────┬─────────┘
                           │
                           ▼
                 ┌───────────────────┐
                 │    Node/Express   │
                 │      Backend      │
                 └───────┬─────┬─────┘
                         │     │
              ┌──────────┘     └──────────┐
              ▼                           ▼
      ┌───────────────┐           ┌───────────────┐
      │  PostgreSQL   │           │ Cloudflare R2 │
      │               │           │               │
      │ Users         │           │ PDFs          │
      │ Papers        │           │               │
      │ Reports       │           │               │
      └───────────────┘           └───────────────┘
              │                           │
              └─────────────┬─────────────┘
                            ▼
                     ┌─────────────┐
                     │    Admin    │
                     │ Moderation  │
                     └─────────────┘
```

**Ek important recommendation:** pehle **database schema + API design + upload/download flow** properly design karna. UI se start mat karna. Is project ki real complexity frontend mein nahi, **file storage, metadata, authentication, duplicate detection aur secure download architecture** mein hai.
