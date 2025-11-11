-- Create empleados (employees) table
CREATE TABLE public.empleados (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre_completo TEXT NOT NULL,
  cargo TEXT NOT NULL,
  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.empleados ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read all active employees
CREATE POLICY "Authenticated users can view active employees"
ON public.empleados
FOR SELECT
TO authenticated
USING (activo = true);

-- Allow authenticated users to insert employees
CREATE POLICY "Authenticated users can insert employees"
ON public.empleados
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow authenticated users to update employees
CREATE POLICY "Authenticated users can update employees"
ON public.empleados
FOR UPDATE
TO authenticated
USING (true);

-- Create function to update timestamps
CREATE OR REPLACE FUNCTION public.update_empleados_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- Create trigger for automatic timestamp updates
CREATE TRIGGER update_empleados_timestamp
BEFORE UPDATE ON public.empleados
FOR EACH ROW
EXECUTE FUNCTION public.update_empleados_updated_at();