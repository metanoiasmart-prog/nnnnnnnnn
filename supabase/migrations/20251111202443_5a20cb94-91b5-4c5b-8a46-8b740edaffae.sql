-- Agregar columna monto_contado a arqueos si no existe
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'arqueos' AND column_name = 'monto_contado'
  ) THEN
    ALTER TABLE public.arqueos ADD COLUMN monto_contado NUMERIC(12,2) NOT NULL DEFAULT 0;
  END IF;
END $$;

-- Crear tabla de recepciones si no existe
CREATE TABLE IF NOT EXISTS public.recepciones (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  traslado_id UUID NOT NULL REFERENCES public.traslados(id) ON DELETE CASCADE,
  turno_receptor_id UUID NOT NULL REFERENCES public.turnos(id) ON DELETE CASCADE,
  monto_recibido NUMERIC(12,2) NOT NULL DEFAULT 0,
  observaciones TEXT,
  fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Habilitar Row Level Security si la tabla se creó
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'recepciones') THEN
    ALTER TABLE public.recepciones ENABLE ROW LEVEL SECURITY;
    
    -- Crear políticas
    DROP POLICY IF EXISTS "Cualquiera puede ver recepciones" ON public.recepciones;
    CREATE POLICY "Cualquiera puede ver recepciones" ON public.recepciones FOR SELECT USING (true);
    
    DROP POLICY IF EXISTS "Cualquiera puede insertar recepciones" ON public.recepciones;
    CREATE POLICY "Cualquiera puede insertar recepciones" ON public.recepciones FOR INSERT WITH CHECK (true);
    
    DROP POLICY IF EXISTS "Cualquiera puede actualizar recepciones" ON public.recepciones;
    CREATE POLICY "Cualquiera puede actualizar recepciones" ON public.recepciones FOR UPDATE USING (true);
    
    -- Crear trigger
    DROP TRIGGER IF EXISTS update_recepciones_updated_at ON public.recepciones;
    CREATE TRIGGER update_recepciones_updated_at
    BEFORE UPDATE ON public.recepciones
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();
  END IF;
END $$;