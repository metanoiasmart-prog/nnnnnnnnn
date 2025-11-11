-- Crear tabla de empleados
CREATE TABLE IF NOT EXISTS public.empleados (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre_completo TEXT NOT NULL,
  cargo TEXT NOT NULL,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.empleados ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Empleados son públicamente legibles" 
ON public.empleados FOR SELECT 
USING (true);

CREATE POLICY "Empleados pueden ser creados por todos" 
ON public.empleados FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Empleados pueden ser actualizados por todos" 
ON public.empleados FOR UPDATE 
USING (true);

-- Crear tabla de cajas
CREATE TABLE IF NOT EXISTS public.cajas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  ubicacion TEXT NOT NULL,
  tipo TEXT NOT NULL CHECK (tipo IN ('comercial', 'principal')),
  activa BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.cajas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Cajas son públicamente legibles" 
ON public.cajas FOR SELECT 
USING (true);

-- Crear tabla de turnos
CREATE TABLE IF NOT EXISTS public.turnos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  caja_id UUID NOT NULL REFERENCES public.cajas(id),
  usuario_id UUID NOT NULL,
  empleado_id UUID REFERENCES public.empleados(id),
  fecha DATE NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fin TIME,
  estado TEXT NOT NULL DEFAULT 'abierto' CHECK (estado IN ('abierto', 'cerrado')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.turnos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Turnos son públicamente legibles" 
ON public.turnos FOR SELECT 
USING (true);

CREATE POLICY "Turnos pueden ser creados por todos" 
ON public.turnos FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Turnos pueden ser actualizados por todos" 
ON public.turnos FOR UPDATE 
USING (true);

-- Crear tabla de aperturas
CREATE TABLE IF NOT EXISTS public.aperturas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  turno_id UUID NOT NULL REFERENCES public.turnos(id),
  monto_inicial DECIMAL(10,2) NOT NULL,
  observaciones TEXT,
  cerrada BOOLEAN DEFAULT false,
  fecha_hora TIMESTAMP WITH TIME ZONE DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.aperturas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Aperturas son públicamente legibles" 
ON public.aperturas FOR SELECT 
USING (true);

CREATE POLICY "Aperturas pueden ser creadas por todos" 
ON public.aperturas FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Aperturas pueden ser actualizadas por todos" 
ON public.aperturas FOR UPDATE 
USING (true);

-- Crear tabla de parámetros
CREATE TABLE IF NOT EXISTS public.parametros (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clave TEXT NOT NULL UNIQUE,
  valor TEXT NOT NULL,
  descripcion TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.parametros ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Parámetros son públicamente legibles" 
ON public.parametros FOR SELECT 
USING (true);

CREATE POLICY "Parámetros pueden ser actualizados por todos" 
ON public.parametros FOR UPDATE 
USING (true);

-- Insertar datos iniciales
INSERT INTO public.cajas (nombre, ubicacion, tipo, activa) 
VALUES ('Caja Planta Baja', 'Planta Baja', 'comercial', true)
ON CONFLICT DO NOTHING;

INSERT INTO public.parametros (clave, valor, descripcion)
VALUES ('umbral_diferencia', '2.00', 'Umbral máximo de diferencia permitido en USD')
ON CONFLICT (clave) DO NOTHING;