-- Crear tabla de turnos
CREATE TABLE public.turnos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  caja_id UUID NOT NULL REFERENCES public.cajas(id) ON DELETE CASCADE,
  empleado_id UUID NOT NULL REFERENCES public.empleados(id) ON DELETE CASCADE,
  fecha DATE NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fin TIME,
  estado TEXT NOT NULL DEFAULT 'abierto',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Crear tabla de aperturas
CREATE TABLE public.aperturas (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  turno_id UUID NOT NULL REFERENCES public.turnos(id) ON DELETE CASCADE,
  monto_inicial NUMERIC(12,2) NOT NULL DEFAULT 0,
  observaciones TEXT,
  cerrada BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Crear tabla de arqueos
CREATE TABLE public.arqueos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  turno_id UUID NOT NULL REFERENCES public.turnos(id) ON DELETE CASCADE,
  monto_final NUMERIC(12,2) NOT NULL DEFAULT 0,
  monto_sistema NUMERIC(12,2) NOT NULL DEFAULT 0,
  diferencia NUMERIC(12,2) NOT NULL DEFAULT 0,
  observaciones TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Crear tabla de pagos a proveedores
CREATE TABLE public.pagos_proveedores (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  turno_id UUID NOT NULL REFERENCES public.turnos(id) ON DELETE CASCADE,
  concepto TEXT NOT NULL,
  valor NUMERIC(12,2) NOT NULL DEFAULT 0,
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Crear tabla de traslados
CREATE TABLE public.traslados (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  turno_id UUID NOT NULL REFERENCES public.turnos(id) ON DELETE CASCADE,
  caja_origen_id UUID NOT NULL REFERENCES public.cajas(id),
  caja_destino_id UUID NOT NULL REFERENCES public.cajas(id),
  monto NUMERIC(12,2) NOT NULL DEFAULT 0,
  estado TEXT NOT NULL DEFAULT 'pendiente',
  observaciones TEXT,
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Crear tabla de parámetros
CREATE TABLE public.parametros (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  clave TEXT NOT NULL UNIQUE,
  valor TEXT NOT NULL,
  descripcion TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Habilitar Row Level Security en todas las tablas
ALTER TABLE public.turnos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.aperturas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.arqueos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pagos_proveedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.traslados ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parametros ENABLE ROW LEVEL SECURITY;

-- Políticas para turnos
CREATE POLICY "Cualquiera puede ver turnos" ON public.turnos FOR SELECT USING (true);
CREATE POLICY "Cualquiera puede insertar turnos" ON public.turnos FOR INSERT WITH CHECK (true);
CREATE POLICY "Cualquiera puede actualizar turnos" ON public.turnos FOR UPDATE USING (true);

-- Políticas para aperturas
CREATE POLICY "Cualquiera puede ver aperturas" ON public.aperturas FOR SELECT USING (true);
CREATE POLICY "Cualquiera puede insertar aperturas" ON public.aperturas FOR INSERT WITH CHECK (true);
CREATE POLICY "Cualquiera puede actualizar aperturas" ON public.aperturas FOR UPDATE USING (true);

-- Políticas para arqueos
CREATE POLICY "Cualquiera puede ver arqueos" ON public.arqueos FOR SELECT USING (true);
CREATE POLICY "Cualquiera puede insertar arqueos" ON public.arqueos FOR INSERT WITH CHECK (true);
CREATE POLICY "Cualquiera puede actualizar arqueos" ON public.arqueos FOR UPDATE USING (true);

-- Políticas para pagos_proveedores
CREATE POLICY "Cualquiera puede ver pagos_proveedores" ON public.pagos_proveedores FOR SELECT USING (true);
CREATE POLICY "Cualquiera puede insertar pagos_proveedores" ON public.pagos_proveedores FOR INSERT WITH CHECK (true);
CREATE POLICY "Cualquiera puede actualizar pagos_proveedores" ON public.pagos_proveedores FOR UPDATE USING (true);

-- Políticas para traslados
CREATE POLICY "Cualquiera puede ver traslados" ON public.traslados FOR SELECT USING (true);
CREATE POLICY "Cualquiera puede insertar traslados" ON public.traslados FOR INSERT WITH CHECK (true);
CREATE POLICY "Cualquiera puede actualizar traslados" ON public.traslados FOR UPDATE USING (true);

-- Políticas para parametros
CREATE POLICY "Cualquiera puede ver parametros" ON public.parametros FOR SELECT USING (true);
CREATE POLICY "Cualquiera puede insertar parametros" ON public.parametros FOR INSERT WITH CHECK (true);
CREATE POLICY "Cualquiera puede actualizar parametros" ON public.parametros FOR UPDATE USING (true);

-- Triggers para actualizar updated_at
CREATE TRIGGER update_turnos_updated_at
BEFORE UPDATE ON public.turnos
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_aperturas_updated_at
BEFORE UPDATE ON public.aperturas
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_arqueos_updated_at
BEFORE UPDATE ON public.arqueos
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_pagos_proveedores_updated_at
BEFORE UPDATE ON public.pagos_proveedores
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_traslados_updated_at
BEFORE UPDATE ON public.traslados
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_parametros_updated_at
BEFORE UPDATE ON public.parametros
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();