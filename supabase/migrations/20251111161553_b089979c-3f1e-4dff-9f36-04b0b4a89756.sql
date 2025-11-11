-- Add missing columns to aperturas table
ALTER TABLE public.aperturas 
ADD COLUMN IF NOT EXISTS fecha_hora TIMESTAMP WITH TIME ZONE DEFAULT now(),
ADD COLUMN IF NOT EXISTS monto_final NUMERIC;

-- Add missing columns to arqueos table
ALTER TABLE public.arqueos
ADD COLUMN IF NOT EXISTS monto_contado NUMERIC,
ADD COLUMN IF NOT EXISTS monto_final NUMERIC,
ADD COLUMN IF NOT EXISTS fecha_hora TIMESTAMP WITH TIME ZONE DEFAULT now();

-- Add pagado_por column to pagos_proveedores (keeping pagador for compatibility)
ALTER TABLE public.pagos_proveedores
ADD COLUMN IF NOT EXISTS pagado_por TEXT;