-- Add missing columns to cajas table
ALTER TABLE public.cajas 
ADD COLUMN tipo TEXT,
ADD COLUMN ubicacion TEXT;

-- Add missing columns to turnos table
ALTER TABLE public.turnos
ADD COLUMN usuario_id UUID;

-- Add missing columns to aperturas table
ALTER TABLE public.aperturas
ADD COLUMN observaciones TEXT,
ADD COLUMN fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now();

-- Add missing columns to arqueos table
ALTER TABLE public.arqueos
ADD COLUMN monto_esperado DECIMAL(10,2),
ADD COLUMN monto_final DECIMAL(10,2),
ADD COLUMN fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now();

-- Add missing columns to pagos_proveedores table
ALTER TABLE public.pagos_proveedores
ADD COLUMN tipo_documento TEXT,
ADD COLUMN numero_documento TEXT,
ADD COLUMN valor DECIMAL(10,2),
ADD COLUMN saldo DECIMAL(10,2),
ADD COLUMN pagado_por UUID REFERENCES public.empleados(id);

-- Update pagos_proveedores to make monto nullable and use valor
ALTER TABLE public.pagos_proveedores
ALTER COLUMN monto DROP NOT NULL;

-- Update traslados table to add missing columns
ALTER TABLE public.traslados
ADD COLUMN arqueo_id UUID REFERENCES public.arqueos(id),
ADD COLUMN caja_origen_id UUID REFERENCES public.cajas(id),
ADD COLUMN caja_destino_id UUID REFERENCES public.cajas(id),
ADD COLUMN monto DECIMAL(10,2);

-- Update traslados to make monto_enviado nullable
ALTER TABLE public.traslados
ALTER COLUMN monto_enviado DROP NOT NULL;

-- Add usuario_receptor_id to recepciones
ALTER TABLE public.recepciones
ADD COLUMN usuario_receptor_id UUID;

-- Insert default parameter for umbral_diferencia
INSERT INTO public.parametros (clave, valor, descripcion) 
VALUES ('umbral_diferencia', '2.00', 'Umbral de diferencia permitido en arqueos')
ON CONFLICT (clave) DO NOTHING;