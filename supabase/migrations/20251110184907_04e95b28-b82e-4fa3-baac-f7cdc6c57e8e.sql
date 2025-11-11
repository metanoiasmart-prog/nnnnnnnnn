-- Create empleados table
CREATE TABLE public.empleados (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre_completo TEXT NOT NULL,
  cargo TEXT NOT NULL,
  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create cajas table
CREATE TABLE public.cajas (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL,
  activa BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create parametros table
CREATE TABLE public.parametros (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  clave TEXT NOT NULL UNIQUE,
  valor TEXT NOT NULL,
  descripcion TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create turnos table
CREATE TABLE public.turnos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  caja_id UUID NOT NULL REFERENCES public.cajas(id),
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
  monto_inicial DECIMAL(10,2) NOT NULL,
  cerrada BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create arqueos table
CREATE TABLE public.arqueos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  apertura_id UUID NOT NULL REFERENCES public.aperturas(id),
  billetes_100 INTEGER NOT NULL DEFAULT 0,
  billetes_50 INTEGER NOT NULL DEFAULT 0,
  billetes_20 INTEGER NOT NULL DEFAULT 0,
  billetes_10 INTEGER NOT NULL DEFAULT 0,
  monedas_5 INTEGER NOT NULL DEFAULT 0,
  monedas_2 INTEGER NOT NULL DEFAULT 0,
  monedas_1 INTEGER NOT NULL DEFAULT 0,
  monto_contado DECIMAL(10,2) NOT NULL,
  monto_teorico DECIMAL(10,2) NOT NULL,
  diferencia DECIMAL(10,2) NOT NULL,
  estado TEXT NOT NULL,
  comentario TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create pagos_proveedores table
CREATE TABLE public.pagos_proveedores (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  proveedor TEXT NOT NULL,
  monto DECIMAL(10,2) NOT NULL,
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create traslados table
CREATE TABLE public.traslados (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  empleado_envia_id UUID NOT NULL REFERENCES public.empleados(id),
  monto_enviado DECIMAL(10,2) NOT NULL,
  comentario TEXT,
  estado TEXT NOT NULL DEFAULT 'pendiente',
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create recepciones table
CREATE TABLE public.recepciones (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  traslado_id UUID NOT NULL REFERENCES public.traslados(id),
  monto_recibido DECIMAL(10,2) NOT NULL,
  diferencia DECIMAL(10,2) NOT NULL,
  comentario TEXT,
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.empleados ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cajas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parametros ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.turnos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.aperturas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.arqueos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pagos_proveedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.traslados ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recepciones ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (adjust as needed based on your security requirements)
CREATE POLICY "Allow all operations on empleados" ON public.empleados FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on cajas" ON public.cajas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on parametros" ON public.parametros FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on turnos" ON public.turnos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on aperturas" ON public.aperturas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on arqueos" ON public.arqueos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on pagos_proveedores" ON public.pagos_proveedores FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on traslados" ON public.traslados FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations on recepciones" ON public.recepciones FOR ALL USING (true) WITH CHECK (true);

-- Insert default parameter for monto inicial
INSERT INTO public.parametros (clave, valor, descripcion) VALUES ('monto_inicial_default', '0', 'Monto inicial por defecto para apertura de caja');