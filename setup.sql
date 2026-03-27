-- Match requests table
CREATE TABLE IF NOT EXISTS match_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  from_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  to_id   uuid REFERENCES profiles(id) ON DELETE CASCADE,
  status  text DEFAULT 'pending', -- pending | accepted | rejected
  created_at timestamptz DEFAULT now(),
  UNIQUE(from_id, to_id)
);

-- Conversations table
CREATE TABLE IF NOT EXISTS conversations (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_a_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  profile_b_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  last_message text,
  updated_at   timestamptz DEFAULT now(),
  created_at   timestamptz DEFAULT now(),
  UNIQUE(profile_a_id, profile_b_id)
);

-- Messages table
CREATE TABLE IF NOT EXISTS messages (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id       uuid REFERENCES profiles(id) ON DELETE CASCADE,
  content         text NOT NULL,
  created_at      timestamptz DEFAULT now()
);

-- RLS: allow anon full access (demo — tighten in production)
ALTER TABLE match_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations   ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages        ENABLE ROW LEVEL SECURITY;

CREATE POLICY "allow all" ON match_requests FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow all" ON conversations   FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow all" ON messages        FOR ALL USING (true) WITH CHECK (true);
