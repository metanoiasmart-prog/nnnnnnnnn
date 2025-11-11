-- Create empleados table
CREATE TABLE public.empleados (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre_completo TEXT NOT NULL,
  cargo TEXT NOT NULL,
  activa BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create cajas table
CREATE TABLE public.cajas (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL,
  ubicacion TEXT NOT NULL,
  tipo TEXT NOT NULL,
  activa BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create turnos table
CREATE TABLE public.turnos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  caja_id UUID NOT NULL REFERENCES public.cajas(id),
  usuario_id UUID NOT NULL,
  empleado_id UUID NOT NULL REFERENCES public.empleados(id),
  fecha DATE NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fin TIME,
  estado TEXT NOT NULL DEFAULT 'abierto',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create aperturas table
CREATE TABLE public.aperturas (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  turno_id UUID NOT NULL REFERENCES public.turnos(id),
  monto_inicial DECIMAL(10, 2) NOT NULL,
  observaciones TEXT,
  cerrada BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create pagos_proveedores table
CREATE TABLE public.pagos_proveedores (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  proveedor TEXT NOT NULL,
  tipo_documento TEXT NOT NULL,
  numero_documento TEXT NOT NULL,
  valor DECIMAL(10, 2) NOT NULL,
  saldo DECIMAL(10, 2) NOT NULL,
  pagador TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create arqueos table
CREATE TABLE public.arqueos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  turno_id UUID NOT NULL REFERENCES public.turnos(id),
  apertura_id UUID NOT NULL REFERENCES public.aperturas(id),
  monto_sistema DECIMAL(10, 2) NOT NULL,
  monto_fisico DECIMAL(10, 2) NOT NULL,
  diferencia DECIMAL(10, 2) NOT NULL,
  observaciones TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create traslados table
CREATE TABLE public.traslados (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  caja_origen UUID NOT NULL REFERENCES public.cajas(id),
  caja_destino UUID NOT NULL REFERENCES public.cajas(id),
  monto DECIMAL(10, 2) NOT NULL,
  empleado_id UUID NOT NULL REFERENCES public.empleados(id),
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL,
  estado TEXT NOT NULL DEFAULT 'pendiente',
  observaciones TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create recepciones table
CREATE TABLE public.recepciones (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  traslado_id UUID NOT NULL REFERENCES public.traslados(id),
  monto_recibido DECIMAL(10, 2) NOT NULL,
  diferencia DECIMAL(10, 2) NOT NULL,
  comentario TEXT,
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create parametros table
CREATE TABLE public.parametros (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  clave TEXT NOT NULL UNIQUE,
  valor TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.empleados ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cajas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.turnos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.aperturas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pagos_proveedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.arqueos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.traslados ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recepciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parametros ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies (allowing all operations for authenticated users for now)
CREATE POLICY "Allow all for authenticated users" ON public.empleados FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated users" ON public.cajas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated users" ON public.turnos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated users" ON public.aperturas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated users" ON public.pagos_proveedores FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated users" ON public.arqueos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated users" ON public.traslados FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated users" ON public.recepciones FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated users" ON public.parametros FOR ALL USING (true) WITH CHECK (true);

-- Create indexes for better performance
CREATE INDEX idx_turnos_caja_id ON public.turnos(caja_id);
CREATE INDEX idx_turnos_empleado_id ON public.turnos(empleado_id);
CREATE INDEX idx_turnos_estado ON public.turnos(estado);
CREATE INDEX idx_aperturas_turno_id ON public.aperturas(turno_id);
CREATE INDEX idx_arqueos_turno_id ON public.arqueos(turno_id);
CREATE INDEX idx_traslados_estado ON public.traslados(estado);
CREATE INDEX idx_recepciones_traslado_id ON public.recepciones(traslado_id);

-- Insert initial data for Caja Planta Baja
INSERT INTO public.cajas (nombre, ubicacion, tipo, activa) 
VALUES ('Caja Principal', 'Planta Baja', 'comercial', true);