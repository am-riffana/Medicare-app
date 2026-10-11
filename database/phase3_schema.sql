-- ============================================================================
-- MediCare Phase 3: Doctor Discovery & Specialization Schema
-- PostgreSQL & Supabase Database Setup Script
-- ============================================================================

-- 1. Create Specializations Table
CREATE TABLE IF NOT EXISTS public.specializations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 2. Create Doctors Directory Table
CREATE TABLE IF NOT EXISTS public.doctors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID, -- References auth.users(id) or users profile
    specialization_id UUID REFERENCES public.specializations(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    qualification TEXT,
    experience_years INTEGER DEFAULT 0 NOT NULL,
    consultation_fee NUMERIC(10, 2) DEFAULT 0.00 NOT NULL,
    about TEXT,
    profile_image TEXT,
    clinic_name TEXT,
    clinic_address TEXT,
    phone TEXT,
    rating NUMERIC(3, 2) DEFAULT 5.0 NOT NULL,
    total_reviews INTEGER DEFAULT 0 NOT NULL,
    is_available BOOLEAN DEFAULT true NOT NULL,
    is_verified BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 3. Performance Indexes
CREATE INDEX IF NOT EXISTS idx_doctors_specialization ON public.doctors(specialization_id);
CREATE INDEX IF NOT EXISTS idx_doctors_verified ON public.doctors(is_verified);
CREATE INDEX IF NOT EXISTS idx_doctors_name ON public.doctors(name);
CREATE INDEX IF NOT EXISTS idx_specializations_active ON public.specializations(is_active);

-- 4. Row Level Security (RLS)
ALTER TABLE public.specializations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.doctors ENABLE ROW LEVEL SECURITY;

-- 5. Specializations RLS Policies
-- Allow public and authenticated users to read active specializations
DROP POLICY IF EXISTS "Allow read access to active specializations" ON public.specializations;
CREATE POLICY "Allow read access to active specializations"
ON public.specializations
FOR SELECT
USING (is_active = true);

-- 6. Doctors RLS Policies
-- Allow public and authenticated users to discover verified doctors
DROP POLICY IF EXISTS "Allow read access to verified doctors" ON public.doctors;
CREATE POLICY "Allow read access to verified doctors"
ON public.doctors
FOR SELECT
USING (is_verified = true);

-- Allow authenticated doctors to update their own profile
DROP POLICY IF EXISTS "Doctors can update their own profile" ON public.doctors;
CREATE POLICY "Doctors can update their own profile"
ON public.doctors
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 7. Seed Sample Specializations (Idempotent)
INSERT INTO public.specializations (name, description, is_active)
VALUES
    ('Cardiology', 'Heart and cardiovascular system care', true),
    ('Neurology', 'Brain and nervous system specialists', true),
    ('Pediatrics', 'Comprehensive healthcare for infants and children', true),
    ('Dermatology', 'Skin, hair, and nail health treatments', true),
    ('Orthopedics', 'Musculoskeletal system, joints, and spine care', true),
    ('Dentistry', 'Dental and oral hygiene and treatments', true),
    ('General Medicine', 'Primary care and internal medicine', true),
    ('Ophthalmology', 'Comprehensive vision and eye health care', true)
ON CONFLICT (name) DO NOTHING;

-- 8. Seed Verified Doctors for Discovery Testing
DO $$
DECLARE
    cardio_id UUID;
    neuro_id UUID;
    pediatric_id UUID;
    derma_id UUID;
    ortho_id UUID;
    general_id UUID;
BEGIN
    SELECT id INTO cardio_id FROM public.specializations WHERE name = 'Cardiology' LIMIT 1;
    SELECT id INTO neuro_id FROM public.specializations WHERE name = 'Neurology' LIMIT 1;
    SELECT id INTO pediatric_id FROM public.specializations WHERE name = 'Pediatrics' LIMIT 1;
    SELECT id INTO derma_id FROM public.specializations WHERE name = 'Dermatology' LIMIT 1;
    SELECT id INTO ortho_id FROM public.specializations WHERE name = 'Orthopedics' LIMIT 1;
    SELECT id INTO general_id FROM public.specializations WHERE name = 'General Medicine' LIMIT 1;

    -- Doctor 1: Cardiologist
    IF NOT EXISTS (SELECT 1 FROM public.doctors WHERE name = 'Dr. Sarah Mitchell') THEN
        INSERT INTO public.doctors (
            name, specialization_id, qualification, experience_years, consultation_fee,
            about, clinic_name, clinic_address, rating, total_reviews, is_available, is_verified
        ) VALUES (
            'Dr. Sarah Mitchell', cardio_id, 'MBBS, MD - Cardiology, FACC', 14, 1200.00,
            'Senior Consultant Cardiologist with over 14 years of clinical experience specializing in non-invasive cardiology, preventive heart health, and echocardiography.',
            'Metro Heart & Vascular Center', 'Suite 401, Central Medicare Plaza', 4.9, 142, true, true
        );
    END IF;

    -- Doctor 2: Neurologist
    IF NOT EXISTS (SELECT 1 FROM public.doctors WHERE name = 'Dr. Alexander Wright') THEN
        INSERT INTO public.doctors (
            name, specialization_id, qualification, experience_years, consultation_fee,
            about, clinic_name, clinic_address, rating, total_reviews, is_available, is_verified
        ) VALUES (
            'Dr. Alexander Wright', neuro_id, 'MBBS, DM - Neurology', 11, 1000.00,
            'Dedicated neurologist focusing on migraine management, stroke rehabilitation, and neuro-diagnostics with exceptional patient-centric care.',
            'NeuroLife Advanced Institute', 'Building B, Healthcare Boulevard', 4.8, 98, true, true
        );
    END IF;

    -- Doctor 3: Pediatrician
    IF NOT EXISTS (SELECT 1 FROM public.doctors WHERE name = 'Dr. Emily Chen') THEN
        INSERT INTO public.doctors (
            name, specialization_id, qualification, experience_years, consultation_fee,
            about, clinic_name, clinic_address, rating, total_reviews, is_available, is_verified
        ) VALUES (
            'Dr. Emily Chen', pediatric_id, 'MBBS, DCH, MD - Pediatrics', 9, 750.00,
            'Passionate pediatric care provider committed to child development, neonatal nutrition, and gentle immunization programs.',
            'Sunshine Childrens Clinic', '12 Harmony Lane, Green Park', 4.9, 215, true, true
        );
    END IF;

    -- Doctor 4: Dermatologist
    IF NOT EXISTS (SELECT 1 FROM public.doctors WHERE name = 'Dr. Marcus Vance') THEN
        INSERT INTO public.doctors (
            name, specialization_id, qualification, experience_years, consultation_fee,
            about, clinic_name, clinic_address, rating, total_reviews, is_available, is_verified
        ) VALUES (
            'Dr. Marcus Vance', derma_id, 'MBBS, MD - Dermatology & Venereology', 8, 850.00,
            'Expert in clinical dermatology, acne therapeutics, laser cosmetology, and allergic skin disorders.',
            'DermaCare Aesthetic Center', 'Floor 2, Royal Wellness Arcade', 4.7, 86, true, true
        );
    END IF;

    -- Doctor 5: Orthopedic Surgeon
    IF NOT EXISTS (SELECT 1 FROM public.doctors WHERE name = 'Dr. Rajesh Nair') THEN
        INSERT INTO public.doctors (
            name, specialization_id, qualification, experience_years, consultation_fee,
            about, clinic_name, clinic_address, rating, total_reviews, is_available, is_verified
        ) VALUES (
            'Dr. Rajesh Nair', ortho_id, 'MBBS, MS - Orthopaedics, MCh', 16, 1100.00,
            'Specialist in joint replacement surgery, arthroscopy, and sports injury rehabilitation.',
            'Apex Bone & Joint Clinic', 'Sector 5, MediCity Campus', 4.8, 174, true, true
        );
    END IF;

    -- Doctor 6: General Physician
    IF NOT EXISTS (SELECT 1 FROM public.doctors WHERE name = 'Dr. Anita Desai') THEN
        INSERT INTO public.doctors (
            name, specialization_id, qualification, experience_years, consultation_fee,
            about, clinic_name, clinic_address, rating, total_reviews, is_available, is_verified
        ) VALUES (
            'Dr. Anita Desai', general_id, 'MBBS, DNB - Family Medicine', 7, 500.00,
            'Comprehensive preventive care, chronic disease management (diabetes & hypertension), and routine healthcare consultations.',
            'MediCare Family Wellness Clinic', 'Block C, Crossway Avenue', 4.8, 129, true, true
        );
    END IF;
END $$;
