-- Create empleados table
CREATE TABLE IF NOT EXISTS public.empleados (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre_completo TEXT NOT NULL,
  cargo TEXT NOT NULL,
  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create cajas table
CREATE TABLE IF NOT EXISTS public.cajas (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL,
  ubicacion TEXT NOT NULL,
  tipo TEXT NOT NULL, -- 'comercial' or 'principal'
  activa BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create turnos table
CREATE TABLE IF NOT EXISTS public.turnos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  caja_id UUID NOT NULL REFERENCES public.cajas(id),
  usuario_id UUID NOT NULL,
  empleado_id UUID REFERENCES public.empleados(id),
  fecha DATE NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fin TIME,
  estado TEXT NOT NULL DEFAULT 'abierto',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create aperturas table
CREATE TABLE IF NOT EXISTS public.aperturas (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  turno_id UUID NOT NULL REFERENCES public.turnos(id),
  monto_inicial DECIMAL(10,2) NOT NULL,
  observaciones TEXT,
  cerrada BOOLEAN NOT NULL DEFAULT false,
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create arqueos table
CREATE TABLE IF NOT EXISTS public.arqueos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  apertura_id UUID NOT NULL REFERENCES public.aperturas(id),
  monto_contado DECIMAL(10,2) NOT NULL,
  monto_esperado DECIMAL(10,2) NOT NULL,
  monto_final DECIMAL(10,2) NOT NULL,
  diferencia DECIMAL(10,2) NOT NULL,
  comentario TEXT,
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create parametros table
CREATE TABLE IF NOT EXISTS public.parametros (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  clave TEXT NOT NULL UNIQUE,
  valor TEXT NOT NULL,
  descripcion TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create pagos_proveedores table
CREATE TABLE IF NOT EXISTS public.pagos_proveedores (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  proveedor TEXT NOT NULL,
  tipo_documento TEXT NOT NULL,
  numero_documento TEXT NOT NULL,
  valor DECIMAL(10,2) NOT NULL,
  saldo DECIMAL(10,2) NOT NULL DEFAULT 0,
  pagado_por TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create traslados table
CREATE TABLE IF NOT EXISTS public.traslados (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  arqueo_id UUID NOT NULL REFERENCES public.arqueos(id),
  caja_origen_id UUID NOT NULL REFERENCES public.cajas(id),
  caja_destino_id UUID NOT NULL REFERENCES public.cajas(id),
  monto DECIMAL(10,2) NOT NULL,
  estado TEXT NOT NULL DEFAULT 'en_transito',
  fecha_hora_envio TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create recepciones table
CREATE TABLE IF NOT EXISTS public.recepciones (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  traslado_id UUID NOT NULL REFERENCES public.traslados(id),
  usuario_receptor_id UUID NOT NULL,
  monto_recibido DECIMAL(10,2) NOT NULL,
  diferencia DECIMAL(10,2) NOT NULL,
  comentario TEXT,
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Insert default parameter for umbral_diferencia
INSERT INTO public.parametros (clave, valor, descripcion)
VALUES ('umbral_diferencia', '2.00', 'Umbral máximo de diferencia permitida en arqueos sin comentario obligatorio')
ON CONFLICT (clave) DO NOTHING;

-- Insert default cajas
INSERT INTO public.cajas (nombre, ubicacion, tipo, activa)
VALUES 
  ('Caja Comercial', 'Planta Baja', 'comercial', true),
  ('Caja Principal', 'Gerencia', 'principal', true)
ON CONFLICT DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_turnos_caja_id ON public.turnos(caja_id);
CREATE INDEX IF NOT EXISTS idx_turnos_empleado_id ON public.turnos(empleado_id);
CREATE INDEX IF NOT EXISTS idx_turnos_estado ON public.turnos(estado);
CREATE INDEX IF NOT EXISTS idx_aperturas_turno_id ON public.aperturas(turno_id);
CREATE INDEX IF NOT EXISTS idx_arqueos_apertura_id ON public.arqueos(apertura_id);
CREATE INDEX IF NOT EXISTS idx_traslados_estado ON public.traslados(estado);
CREATE INDEX IF NOT EXISTS idx_recepciones_traslado_id ON public.recepciones(traslado_id);