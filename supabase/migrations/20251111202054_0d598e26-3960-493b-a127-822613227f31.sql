-- Crear tabla de cajas
CREATE TABLE public.cajas (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL,
  ubicacion TEXT NOT NULL,
  tipo TEXT NOT NULL DEFAULT 'comercial',
  activa BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Crear tabla de empleados
CREATE TABLE public.empleados (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre_completo TEXT NOT NULL,
  cargo TEXT NOT NULL,
  activa BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Habilitar Row Level Security
ALTER TABLE public.cajas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.empleados ENABLE ROW LEVEL SECURITY;

-- Políticas para cajas (acceso público para lectura, ya que es una app interna)
CREATE POLICY "Cualquiera puede ver cajas activas"
ON public.cajas
FOR SELECT
USING (true);

CREATE POLICY "Cualquiera puede insertar cajas"
ON public.cajas
FOR INSERT
WITH CHECK (true);

CREATE POLICY "Cualquiera puede actualizar cajas"
ON public.cajas
FOR UPDATE
USING (true);

-- Políticas para empleados (acceso público para lectura)
CREATE POLICY "Cualquiera puede ver empleados activos"
ON public.empleados
FOR SELECT
USING (true);

CREATE POLICY "Cualquiera puede insertar empleados"
ON public.empleados
FOR INSERT
WITH CHECK (true);

CREATE POLICY "Cualquiera puede actualizar empleados"
ON public.empleados
FOR UPDATE
USING (true);

-- Función para actualizar timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Trigger para cajas
CREATE TRIGGER update_cajas_updated_at
BEFORE UPDATE ON public.cajas
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger para empleados
CREATE TRIGGER update_empleados_updated_at
BEFORE UPDATE ON public.empleados
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Insertar caja por defecto "Planta Baja"
INSERT INTO public.cajas (nombre, ubicacion, tipo, activa)
VALUES ('Caja Principal', 'Planta Baja', 'comercial', true);