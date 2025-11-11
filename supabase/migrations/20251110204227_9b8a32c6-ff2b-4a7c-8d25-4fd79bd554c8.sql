-- Modificar políticas de empleados para permitir acceso público
DROP POLICY IF EXISTS "Authenticated users can view active employees" ON public.empleados;
DROP POLICY IF EXISTS "Authenticated users can insert employees" ON public.empleados;
DROP POLICY IF EXISTS "Authenticated users can update employees" ON public.empleados;

CREATE POLICY "Allow public read access to active employees"
ON public.empleados
FOR SELECT
USING (activo = true);

CREATE POLICY "Allow public insert employees"
ON public.empleados
FOR INSERT
WITH CHECK (true);

CREATE POLICY "Allow public update employees"
ON public.empleados
FOR UPDATE
USING (true);

-- Crear tabla de cajas
CREATE TABLE IF NOT EXISTS public.cajas (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL,
  tipo TEXT NOT NULL CHECK (tipo IN ('comercial', 'principal')),
  ubicacion TEXT,
  activa BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.cajas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public access to cajas"
ON public.cajas
FOR ALL
USING (true)
WITH CHECK (true);

-- Crear tabla de turnos
CREATE TABLE IF NOT EXISTS public.turnos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  caja_id UUID NOT NULL REFERENCES public.cajas(id) ON DELETE CASCADE,
  usuario_id UUID,
  empleado_id UUID REFERENCES public.empleados(id),
  fecha DATE NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fin TIME,
  estado TEXT NOT NULL DEFAULT 'abierto' CHECK (estado IN ('abierto', 'cerrado')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.turnos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public access to turnos"
ON public.turnos
FOR ALL
USING (true)
WITH CHECK (true);

-- Crear tabla de aperturas
CREATE TABLE IF NOT EXISTS public.aperturas (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  turno_id UUID NOT NULL REFERENCES public.turnos(id) ON DELETE CASCADE,
  monto_inicial DECIMAL(15,2) NOT NULL DEFAULT 0,
  observaciones TEXT,
  cerrada BOOLEAN NOT NULL DEFAULT false,
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.aperturas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public access to aperturas"
ON public.aperturas
FOR ALL
USING (true)
WITH CHECK (true);

-- Crear tabla de arqueos
CREATE TABLE IF NOT EXISTS public.arqueos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  apertura_id UUID NOT NULL REFERENCES public.aperturas(id) ON DELETE CASCADE,
  monto_contado DECIMAL(15,2) NOT NULL,
  monto_esperado DECIMAL(15,2) NOT NULL,
  monto_final DECIMAL(15,2) NOT NULL DEFAULT 0,
  monto_teorico DECIMAL(15,2) NOT NULL DEFAULT 0,
  diferencia DECIMAL(15,2) NOT NULL DEFAULT 0,
  estado TEXT NOT NULL DEFAULT 'normal' CHECK (estado IN ('normal', 'observado')),
  comentario TEXT,
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.arqueos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public access to arqueos"
ON public.arqueos
FOR ALL
USING (true)
WITH CHECK (true);

-- Crear tabla de pagos a proveedores
CREATE TABLE IF NOT EXISTS public.pagos_proveedores (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  proveedor TEXT NOT NULL,
  tipo_documento TEXT NOT NULL,
  numero_documento TEXT,
  valor DECIMAL(15,2) NOT NULL,
  saldo DECIMAL(15,2) NOT NULL DEFAULT 0,
  pagado_por UUID REFERENCES public.empleados(id),
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.pagos_proveedores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public access to pagos_proveedores"
ON public.pagos_proveedores
FOR ALL
USING (true)
WITH CHECK (true);

-- Crear tabla de parámetros del sistema
CREATE TABLE IF NOT EXISTS public.parametros (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  clave TEXT NOT NULL UNIQUE,
  valor TEXT NOT NULL,
  descripcion TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.parametros ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public access to parametros"
ON public.parametros
FOR ALL
USING (true)
WITH CHECK (true);

-- Insertar parámetros iniciales
INSERT INTO public.parametros (clave, valor, descripcion)
VALUES ('umbral_diferencia', '2.00', 'Umbral de diferencia permitido en arqueos (USD)')
ON CONFLICT (clave) DO NOTHING;

-- Crear tabla de traslados
CREATE TABLE IF NOT EXISTS public.traslados (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  arqueo_id UUID NOT NULL REFERENCES public.arqueos(id) ON DELETE CASCADE,
  caja_origen_id UUID NOT NULL REFERENCES public.cajas(id),
  caja_destino_id UUID NOT NULL REFERENCES public.cajas(id),
  monto DECIMAL(15,2) NOT NULL,
  empleado_envia_id UUID REFERENCES public.empleados(id),
  estado TEXT NOT NULL DEFAULT 'en_transito' CHECK (estado IN ('en_transito', 'recibido', 'observado')),
  fecha_hora_envio TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.traslados ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public access to traslados"
ON public.traslados
FOR ALL
USING (true)
WITH CHECK (true);

-- Crear tabla de recepciones
CREATE TABLE IF NOT EXISTS public.recepciones (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  traslado_id UUID NOT NULL REFERENCES public.traslados(id) ON DELETE CASCADE,
  usuario_receptor_id UUID,
  monto_recibido DECIMAL(15,2) NOT NULL DEFAULT 0,
  diferencia DECIMAL(15,2) NOT NULL DEFAULT 0,
  comentario TEXT,
  fecha_hora TIMESTAMP WITH TIME ZONE DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.recepciones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public access to recepciones"
ON public.recepciones
FOR ALL
USING (true)
WITH CHECK (true);

-- Insertar datos iniciales de cajas
INSERT INTO public.cajas (nombre, tipo, ubicacion, activa)
VALUES 
  ('Caja Comercial - Planta Baja', 'comercial', 'Planta Baja', true),
  ('Caja Principal', 'principal', 'Administración', true)
ON CONFLICT DO NOTHING;

-- Crear triggers para updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
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

DROP TRIGGER IF EXISTS update_cajas_updated_at ON public.cajas;
CREATE TRIGGER update_cajas_updated_at
BEFORE UPDATE ON public.cajas
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_turnos_updated_at ON public.turnos;
CREATE TRIGGER update_turnos_updated_at
BEFORE UPDATE ON public.turnos
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_aperturas_updated_at ON public.aperturas;
CREATE TRIGGER update_aperturas_updated_at
BEFORE UPDATE ON public.aperturas
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_arqueos_updated_at ON public.arqueos;
CREATE TRIGGER update_arqueos_updated_at
BEFORE UPDATE ON public.arqueos
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_pagos_proveedores_updated_at ON public.pagos_proveedores;
CREATE TRIGGER update_pagos_proveedores_updated_at
BEFORE UPDATE ON public.pagos_proveedores
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_parametros_updated_at ON public.parametros;
CREATE TRIGGER update_parametros_updated_at
BEFORE UPDATE ON public.parametros
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_traslados_updated_at ON public.traslados;
CREATE TRIGGER update_traslados_updated_at
BEFORE UPDATE ON public.traslados
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_recepciones_updated_at ON public.recepciones;
CREATE TRIGGER update_recepciones_updated_at
BEFORE UPDATE ON public.recepciones
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();