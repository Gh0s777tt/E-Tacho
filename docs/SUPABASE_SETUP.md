# Supabase setup (one-time, ~5 minutes)

Supabase is a **separate service** — the project is not on Railway or Vercel.
You create one dedicated project for E-Tacho, then paste its URL + anon key.

> Do **not** use a management/personal access token (`sbp_…`) or the
> `service_role` key in the app. Only the **Project URL** and **anon public key**
> go into the client.

## 1. Create the project
1. Go to **https://supabase.com/dashboard/projects** (sign in — GitHub login works).
2. Click **New project**.
3. Fill in:
   - **Name**: `e-tacho`
   - **Database password**: generate a strong one and save it (needed only for
     direct DB access later).
   - **Region**: **Central EU (Frankfurt)** — closest to Poland.
   - **Plan**: Free.
4. Click **Create new project** and wait ~1–2 minutes until it is *Active*.

If you don't see any project, it simply hasn't been created yet — there is no
project until you click **New project**.

## 2. Create the table (activity events)
1. In the project: **SQL Editor** → **New query**.
2. Paste the contents of [`supabase_schema.sql`](supabase_schema.sql) and **Run**.
   This creates the `activity_events` table with Row Level Security.

## 3. Get the URL + anon key
1. **Project Settings** (gear icon) → **API**.
2. Copy:
   - **Project URL** → `https://YOUR-PROJECT.supabase.co`
   - **anon public** key → `eyJ…` (this is public/client-safe; RLS protects data)

## 4. Point the app at your project
Copy `env.example.json` to `env.json` (already git-ignored) and fill it in:

```json
{
  "SUPABASE_URL": "https://YOUR-PROJECT.supabase.co",
  "SUPABASE_ANON_KEY": "eyJ..."
}
```

Then run:

```bash
flutter run --dart-define-from-file=env.json
```

Without `env.json` (or the `--dart-define`s) the app keeps working on the local
in-memory auth stub — so you can develop offline and switch to real Supabase any
time.

## 5. (Optional) Google / Apple sign-in
Email/password works out of the box. For social sign-in, enable the providers in
**Authentication → Providers** in Supabase and configure platform deep links
(Android `intent-filter`, iOS URL types) — that's a later, device-side step.

## Security reminder
If you ever pasted an access token somewhere public, **rotate it**
(Supabase → Account → Access Tokens). The anon key is meant to be public; a
`service_role` key or `sbp_` token is not.
