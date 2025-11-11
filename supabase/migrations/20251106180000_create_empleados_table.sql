/*
  # Crear tabla de empleados

  1. Nueva Tabla
    - `empleados`
      - `id` (uuid, primary key)
      - `nombre_completo` (text, not null)
      - `cargo` (text, not null)
      - `activo` (boolean, default true)
      - `created_at` (timestamptz, default now())

  2. Security
    - Enable RLS en tabla `empleados`
    - Políticas restrictivas para autenticación
*/

CREATE TABLE IF NOT EXISTS empleados (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre_completo text NOT NULL,
  cargo text NOT NULL,
  activo boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE empleados ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden leer empleados activos"
  ON empleados FOR SELECT
  TO authenticated
  USING (activo = true);

CREATE POLICY "Usuarios autenticados pueden crear empleados"
  ON empleados FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden actualizar empleados"
  ON empleados FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Agregar campo empleado_id a turnos
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'turnos' AND column_name = 'empleado_id'
  ) THEN
    ALTER TABLE turnos ADD COLUMN empleado_id uuid REFERENCES empleados(id);
  END IF;
END $$;

-- Agregar monto_final a arqueos
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'arqueos' AND column_name = 'monto_final'
  ) THEN
    ALTER TABLE arqueos ADD COLUMN monto_final numeric DEFAULT 0;
  END IF;
END $$;

-- Insertar empleados de ejemplo
INSERT INTO empleados (nombre_completo, cargo) VALUES
  ('Juan Pérez', 'Cajero'),
  ('María González', 'Supervisor'),
  ('Carlos Rodríguez', 'Cajero')
ON CONFLICT DO NOTHING;
