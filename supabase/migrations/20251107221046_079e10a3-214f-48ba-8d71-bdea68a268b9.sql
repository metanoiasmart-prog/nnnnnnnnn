-- Aumentar el tamaño de las columnas DECIMAL para evitar overflow
ALTER TABLE public.aperturas 
  ALTER COLUMN monto_inicial TYPE DECIMAL(15,2);

ALTER TABLE public.arqueos 
  ALTER COLUMN monto_contado TYPE DECIMAL(15,2),
  ALTER COLUMN monto_esperado TYPE DECIMAL(15,2),
  ALTER COLUMN monto_final TYPE DECIMAL(15,2),
  ALTER COLUMN diferencia TYPE DECIMAL(15,2);

ALTER TABLE public.traslados 
  ALTER COLUMN monto TYPE DECIMAL(15,2);

ALTER TABLE public.recepciones 
  ALTER COLUMN monto_recibido TYPE DECIMAL(15,2),
  ALTER COLUMN diferencia TYPE DECIMAL(15,2);

ALTER TABLE public.pagos_proveedores 
  ALTER COLUMN valor TYPE DECIMAL(15,2),
  ALTER COLUMN saldo TYPE DECIMAL(15,2);