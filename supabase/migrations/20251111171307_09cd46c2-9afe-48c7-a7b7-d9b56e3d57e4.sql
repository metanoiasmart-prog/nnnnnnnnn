-- Crear tabla de empleados
CREATE TABLE public.empleados (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre_completo TEXT NOT NULL,
  cargo TEXT NOT NULL,
  activa BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Crear tabla de cajas
CREATE TABLE public.cajas (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL,
  ubicacion TEXT NOT NULL,
  tipo TEXT NOT NULL,
  activa BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Crear tabla de turnos
CREATE TABLE public.turnos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  caja_id UUID NOT NULL REFERENCES public.cajas(id) ON DELETE CASCADE,
  empleado_id UUID NOT NULL REFERENCES public.empleados(id),
  fecha DATE NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fin TIME,
  estado TEXT NOT NULL DEFAULT 'abierto',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Crear tabla de aperturas
CREATE TABLE public.aperturas (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  turno_id UUID NOT NULL REFERENCES public.turnos(id) ON DELETE CASCADE,
  monto_inicial DECIMAL(10,2) NOT NULL,
  cerrada BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Crear tabla de pagos a proveedores
CREATE TABLE public.pagos_proveedores (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  turno_id UUID NOT NULL REFERENCES public.turnos(id) ON DELETE CASCADE,
  concepto TEXT NOT NULL,
  valor DECIMAL(10,2) NOT NULL,
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Crear tabla de arqueos
CREATE TABLE public.arqueos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  turno_id UUID NOT NULL REFERENCES public.turnos(id) ON DELETE CASCADE,
  monto_final DECIMAL(10,2) NOT NULL,
  monto_contado DECIMAL(10,2) NOT NULL,
  total_pagos_proveedores DECIMAL(10,2) NOT NULL DEFAULT 0,
  diferencia DECIMAL(10,2) NOT NULL,
  comentario TEXT,
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Crear tabla de traslados
CREATE TABLE public.traslados (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  turno_id UUID NOT NULL REFERENCES public.turnos(id) ON DELETE CASCADE,
  empleado_envia_id UUID NOT NULL REFERENCES public.empleados(id),
  monto DECIMAL(10,2) NOT NULL,
  estado TEXT NOT NULL DEFAULT 'pendiente',
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Crear tabla de recepciones
CREATE TABLE public.recepciones (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  traslado_id UUID NOT NULL REFERENCES public.traslados(id) ON DELETE CASCADE,
  empleado_recibe_id UUID NOT NULL REFERENCES public.empleados(id),
  monto_recibido DECIMAL(10,2) NOT NULL,
  diferencia DECIMAL(10,2) NOT NULL,
  comentario TEXT,
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Crear tabla de parámetros
CREATE TABLE public.parametros (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  clave TEXT NOT NULL UNIQUE,
  valor TEXT NOT NULL,
  descripcion TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Habilitar RLS en todas las tablas
ALTER TABLE public.empleados ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cajas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.turnos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.aperturas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pagos_proveedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.arqueos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.traslados ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recepciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parametros ENABLE ROW LEVEL SECURITY;

-- Políticas RLS (acceso público por ahora para MVP)
CREATE POLICY "Permitir todo en empleados" ON public.empleados FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en cajas" ON public.cajas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en turnos" ON public.turnos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en aperturas" ON public.aperturas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en pagos_proveedores" ON public.pagos_proveedores FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en arqueos" ON public.arqueos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en traslados" ON public.traslados FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en recepciones" ON public.recepciones FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en parametros" ON public.parametros FOR ALL USING (true) WITH CHECK (true);

-- Crear índices para mejorar rendimiento
CREATE INDEX idx_turnos_caja_id ON public.turnos(caja_id);
CREATE INDEX idx_turnos_empleado_id ON public.turnos(empleado_id);
CREATE INDEX idx_turnos_fecha ON public.turnos(fecha);
CREATE INDEX idx_aperturas_turno_id ON public.aperturas(turno_id);
CREATE INDEX idx_pagos_proveedores_turno_id ON public.pagos_proveedores(turno_id);
CREATE INDEX idx_arqueos_turno_id ON public.arqueos(turno_id);
CREATE INDEX idx_traslados_turno_id ON public.traslados(turno_id);
CREATE INDEX idx_recepciones_traslado_id ON public.recepciones(traslado_id);