-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.profiles (
  id uuid NOT NULL,
  full_name text,
  role text DEFAULT 'User'::text CHECK (role = ANY (ARRAY['Admin'::text, 'Helpdesk'::text, 'User'::text])),
  email text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.tickets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  title text NOT NULL,
  description text,
  status text DEFAULT 'Open'::text CHECK (status = ANY (ARRAY['Open'::text, 'In Progress'::text, 'Resolved'::text, 'Closed'::text])),
  priority text CHECK (priority = ANY (ARRAY['Low'::text, 'Medium'::text, 'High'::text])),
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  user_name text,
  updated_at timestamp with time zone DEFAULT now(),
  image_url text,
  assigned_to text,
  CONSTRAINT tickets_pkey PRIMARY KEY (id),
  CONSTRAINT tickets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.ticket_comments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_id uuid NOT NULL,
  author_id uuid NOT NULL,
  author_name text NOT NULL,
  author_role text NOT NULL CHECK (author_role = ANY (ARRAY['User'::text, 'Helpdesk'::text, 'Admin'::text])),
  message text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT ticket_comments_pkey PRIMARY KEY (id),
  CONSTRAINT ticket_comments_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id),
  CONSTRAINT ticket_comments_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.ticket_tracking (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_id uuid NOT NULL,
  actor_name text NOT NULL,
  message text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT ticket_tracking_pkey PRIMARY KEY (id),
  CONSTRAINT ticket_tracking_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id)
);
CREATE TABLE public.ticket_notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  message text NOT NULL,
  ticket_id uuid NOT NULL,
  target_role text NOT NULL CHECK (target_role = ANY (ARRAY['User'::text, 'Helpdesk'::text, 'Admin'::text])),
  target_user_id uuid,
  is_read boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT ticket_notifications_pkey PRIMARY KEY (id),
  CONSTRAINT ticket_notifications_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id),
  CONSTRAINT ticket_notifications_target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES public.profiles(id)
);