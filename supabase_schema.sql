-- TokoWA SaaS SQL Blueprint Schema
-- Copy-paste this exact code into your Supabase SQL Editor to prepare your Backend

-- 1. Enable UUID Extension (Already enabled by default mostly, but safe to run)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Create Stores Table (Tenants)
CREATE TABLE IF NOT EXISTS public.stores (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    store_name VARCHAR(150) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    whatsapp_number VARCHAR(25) NOT NULL,
    message_template TEXT DEFAULT '*Pesanan Baru via Website*
------------------------------
[ITEMS_LIST]
------------------------------
*Total: [TOTAL]*

Mohon diproses, terima kasih!',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Protect Tenant Store Rows
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can edit their own store" ON public.stores FOR ALL USING (auth.uid() = owner_id);
CREATE POLICY "Public can view active stores by slug" ON public.stores FOR SELECT USING (is_active = true);


-- 3. Create Products Table
CREATE TABLE IF NOT EXISTS public.products (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price BIGINT NOT NULL DEFAULT 0,
    stock INTEGER NOT NULL DEFAULT 0,
    category VARCHAR(100),
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Protect Tenant Products
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage products of their stores" ON public.products FOR ALL USING (
  store_id IN (SELECT id FROM public.stores WHERE owner_id = auth.uid())
);
CREATE POLICY "Public can view active products" ON public.products FOR SELECT USING (is_active = true);


-- Next Steps: Enable Row Level Security Policies via Supabase Dashboard UI if you don't run these policies above.
