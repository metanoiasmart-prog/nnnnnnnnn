-- Create empleados (employees) table
CREATE TABLE public.empleados (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre_completo TEXT NOT NULL,
  cargo TEXT NOT NULL,
  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create cajas (cash registers) table
CREATE TABLE public.cajas (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL,
  tipo TEXT NOT NULL CHECK (tipo IN ('comercial', 'principal')),
  ubicacion TEXT NOT NULL,
  activa BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create turnos (shifts) table
CREATE TABLE public.turnos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  caja_id UUID NOT NULL REFERENCES public.cajas(id),
  usuario_id UUID NOT NULL,
  empleado_id UUID NOT NULL REFERENCES public.empleados(id),
  fecha DATE NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fin TIME,
  estado TEXT NOT NULL CHECK (estado IN ('abierto', 'cerrado')) DEFAULT 'abierto',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create aperturas (openings) table
CREATE TABLE public.aperturas (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  turno_id UUID NOT NULL REFERENCES public.turnos(id),
  monto_inicial DECIMAL(10,2) NOT NULL,
  observaciones TEXT,
  cerrada BOOLEAN NOT NULL DEFAULT false,
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create arqueos (audits) table
CREATE TABLE public.arqueos (
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

-- Create traslados (transfers) table
CREATE TABLE public.traslados (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  arqueo_id UUID NOT NULL REFERENCES public.arqueos(id),
  caja_origen_id UUID NOT NULL REFERENCES public.cajas(id),
  caja_destino_id UUID NOT NULL REFERENCES public.cajas(id),
  monto DECIMAL(10,2) NOT NULL,
  estado TEXT NOT NULL CHECK (estado IN ('en_transito', 'recibido', 'observado')) DEFAULT 'en_transito',
  fecha_hora_envio TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create recepciones (receptions) table
CREATE TABLE public.recepciones (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  traslado_id UUID NOT NULL REFERENCES public.traslados(id),
  usuario_receptor_id UUID NOT NULL,
  monto_recibido DECIMAL(10,2) NOT NULL,
  diferencia DECIMAL(10,2) NOT NULL,
  comentario TEXT,
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create pagos_proveedores (supplier payments) table
CREATE TABLE public.pagos_proveedores (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  proveedor TEXT NOT NULL,
  tipo_documento TEXT NOT NULL,
  numero_documento TEXT NOT NULL,
  valor DECIMAL(10,2) NOT NULL,
  saldo DECIMAL(10,2) NOT NULL DEFAULT 0,
  pagado_por UUID REFERENCES public.empleados(id),
  fecha_pago TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create parametros (parameters) table
CREATE TABLE public.parametros (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  clave TEXT NOT NULL UNIQUE,
  valor TEXT NOT NULL,
  descripcion TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create profiles table
CREATE TABLE public.profiles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE,
  nombre_completo TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable Row Level Security on all tables
ALTER TABLE public.empleados ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cajas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.turnos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.aperturas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.arqueos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.traslados ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recepciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pagos_proveedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parametros ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create RLS policies (allowing all operations for now - should be customized based on requirements)
CREATE POLICY "Allow all operations on empleados" ON public.empleados FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on cajas" ON public.cajas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on turnos" ON public.turnos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on aperturas" ON public.aperturas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on arqueos" ON public.arqueos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on traslados" ON public.traslados FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on recepciones" ON public.recepciones FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on pagos_proveedores" ON public.pagos_proveedores FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on parametros" ON public.parametros FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on profiles" ON public.profiles FOR ALL USING (true) WITH CHECK (true);

-- Create indexes for better performance
CREATE INDEX idx_turnos_caja_id ON public.turnos(caja_id);
CREATE INDEX idx_turnos_empleado_id ON public.turnos(empleado_id);
CREATE INDEX idx_turnos_usuario_id ON public.turnos(usuario_id);
CREATE INDEX idx_turnos_estado ON public.turnos(estado);
CREATE INDEX idx_aperturas_turno_id ON public.aperturas(turno_id);
CREATE INDEX idx_arqueos_apertura_id ON public.arqueos(apertura_id);
CREATE INDEX idx_traslados_arqueo_id ON public.traslados(arqueo_id);
CREATE INDEX idx_traslados_estado ON public.traslados(estado);
CREATE INDEX idx_recepciones_traslado_id ON public.recepciones(traslado_id);

-- Insert default data
INSERT INTO public.parametros (clave, valor, descripcion) VALUES 
  ('umbral_diferencia', '2.00', 'Umbral de diferencia en USD para requerir comentario en arqueos');

-- Insert default cash registers
INSERT INTO public.cajas (nombre, tipo, ubicacion) VALUES
  ('Caja Planta Baja', 'comercial', 'Planta Baja'),
  ('Caja Principal', 'principal', 'Oficina Central');

-- Insert default employees
INSERT INTO public.empleados (nombre_completo, cargo) VALUES
  ('Juan Pérez', 'Cajero'),
  ('María González', 'Supervisor'),
  ('Carlos Rodríguez', 'Gerente');