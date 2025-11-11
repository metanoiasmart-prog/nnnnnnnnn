/*
  # Agregar tabla de pagos a proveedores

  1. Nueva Tabla
    - `pagos_proveedores`
      - `id` (uuid, primary key)
      - `proveedor` (text, nombre del proveedor)
      - `tipo_documento` (text, tipo de documento)
      - `numero_documento` (text, número de documento)
      - `valor` (numeric, valor pagado)
      - `saldo` (numeric, saldo restante)
      - `pagado_por` (text, empleado que pagó)
      - `created_at` (timestamptz)

  2. Seguridad
    - Habilitar RLS
    - Políticas para usuarios autenticados
*/

CREATE TABLE IF NOT EXISTS public.pagos_proveedores (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  proveedor text NOT NULL,
  tipo_documento text NOT NULL CHECK (tipo_documento IN ('Factura', 'Nota de venta', 'Doc. no autorizado', 'Devolución', 'Recepción')),
  numero_documento text NOT NULL,
  valor numeric NOT NULL DEFAULT 0 CHECK (valor >= 0),
  saldo numeric NOT NULL DEFAULT 0,
  pagado_por text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.pagos_proveedores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view pagos_proveedores"
  ON public.pagos_proveedores FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert pagos_proveedores"
  ON public.pagos_proveedores FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update pagos_proveedores"
  ON public.pagos_proveedores FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete pagos_proveedores"
  ON public.pagos_proveedores FOR DELETE
  TO authenticated
  USING (true);

-- Crear secuencias para numeración automática
CREATE SEQUENCE IF NOT EXISTS public.seq_doc_no_autorizado START WITH 1;
CREATE SEQUENCE IF NOT EXISTS public.seq_devolucion START WITH 1;
CREATE SEQUENCE IF NOT EXISTS public.seq_recepcion START WITH 1;