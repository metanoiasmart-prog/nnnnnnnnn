-- Habilitar RLS en todas las tablas
ALTER TABLE public.aperturas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.arqueos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cajas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.empleados ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pagos_proveedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parametros ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recepciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.traslados ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.turnos ENABLE ROW LEVEL SECURITY;

-- Políticas para aperturas
CREATE POLICY "Permitir todas las operaciones en aperturas"
  ON public.aperturas FOR ALL
  USING (true)
  WITH CHECK (true);

-- Políticas para arqueos
CREATE POLICY "Permitir todas las operaciones en arqueos"
  ON public.arqueos FOR ALL
  USING (true)
  WITH CHECK (true);

-- Políticas para cajas
CREATE POLICY "Permitir todas las operaciones en cajas"
  ON public.cajas FOR ALL
  USING (true)
  WITH CHECK (true);

-- Políticas para empleados
CREATE POLICY "Permitir todas las operaciones en empleados"
  ON public.empleados FOR ALL
  USING (true)
  WITH CHECK (true);

-- Políticas para pagos_proveedores
CREATE POLICY "Permitir todas las operaciones en pagos_proveedores"
  ON public.pagos_proveedores FOR ALL
  USING (true)
  WITH CHECK (true);

-- Políticas para parametros
CREATE POLICY "Permitir todas las operaciones en parametros"
  ON public.parametros FOR ALL
  USING (true)
  WITH CHECK (true);

-- Políticas para recepciones
CREATE POLICY "Permitir todas las operaciones en recepciones"
  ON public.recepciones FOR ALL
  USING (true)
  WITH CHECK (true);

-- Políticas para traslados
CREATE POLICY "Permitir todas las operaciones en traslados"
  ON public.traslados FOR ALL
  USING (true)
  WITH CHECK (true);

-- Políticas para turnos
CREATE POLICY "Permitir todas las operaciones en turnos"
  ON public.turnos FOR ALL
  USING (true)
  WITH CHECK (true);