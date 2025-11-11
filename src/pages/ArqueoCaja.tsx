import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import { ArrowLeft, Loader2, AlertCircle, Plus, Trash2, Calculator, FileText, User, DollarSign } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { EmpleadoSelector } from "@/components/EmpleadoSelector";

const ArqueoCaja = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [loading, setLoading] = useState(false);
  const [loadingData, setLoadingData] = useState(true);
  const [userId, setUserId] = useState<string>("");
  const [aperturaActiva, setAperturaActiva] = useState<any>(null);

  const [formData, setFormData] = useState({
    empleadoId: "",
    montoContado: "",
    montoFinal: "",
    comentario: "",
  });

  const [diferencia, setDiferencia] = useState<number | null>(null);
  const [pagosProveedores, setPagosProveedores] = useState<any[]>([]);
  const [contadorDocNoAutorizado, setContadorDocNoAutorizado] = useState(1);
  const [contadorDevolucion, setContadorDevolucion] = useState(1);
  const [contadorRecepcion, setContadorRecepcion] = useState(1);

  useEffect(() => {
    loadData();
  }, []);

  useEffect(() => {
    if (formData.montoFinal && formData.montoContado) {
      const montoFinalNum = parseFloat(formData.montoFinal);
      const montoContadoNum = parseFloat(formData.montoContado);
      const totalPagos = pagosProveedores.reduce((sum, pago) => sum + (parseFloat(pago.valor) || 0), 0);
      const montoEsperado = montoFinalNum - totalPagos; // Monto Final - Pagos = Monto esperado
      const diferenciaCalculada = montoEsperado - montoContadoNum; // Esperado - Contado = Diferencia
      setDiferencia(diferenciaCalculada);
    } else {
      setDiferencia(null);
    }
  }, [formData.montoFinal, formData.montoContado, pagosProveedores]);

  useEffect(() => {
    if (formData.montoFinal && pagosProveedores.length > 0) {
      const montoFinalNum = parseFloat(formData.montoFinal);
      setPagosProveedores(pagosProveedores.map(pago => ({
        ...pago,
        saldo: pago.saldo || montoFinalNum.toString()
      })));
    }
  }, [formData.montoFinal]);

  const agregarPagoProveedor = () => {
    setPagosProveedores([...pagosProveedores, {
      id: Date.now(),
      proveedor: "",
      tipo_documento: "Factura",
      numero_documento: "",
      valor: "",
      saldo: formData.montoFinal || "",
      empleado_id: ""
    }]);
  };

  const eliminarPagoProveedor = (id: number) => {
    setPagosProveedores(pagosProveedores.filter(pago => pago.id !== id));
  };

  const actualizarPagoProveedor = (id: number, campo: string, valor: any) => {
    setPagosProveedores(pagosProveedores.map(pago => {
      if (pago.id === id) {
        const updated = { ...pago, [campo]: valor };

        if (campo === "tipo_documento") {
          if (valor === "Doc. no autorizado") {
            updated.numero_documento = `DNA-${String(contadorDocNoAutorizado).padStart(4, "0")}`;
            setContadorDocNoAutorizado(contadorDocNoAutorizado + 1);
          } else if (valor === "Devolución") {
            updated.numero_documento = `DEV-${String(contadorDevolucion).padStart(4, "0")}`;
            setContadorDevolucion(contadorDevolucion + 1);
          } else if (valor === "Recepción") {
            updated.numero_documento = `REC-${String(contadorRecepcion).padStart(4, "0")}`;
            setContadorRecepcion(contadorRecepcion + 1);
          } else {
            updated.numero_documento = "";
          }
        }

        return updated;
      }
      return pago;
    }));
  };

  const loadData = async () => {
    try {
      const userId = "00000000-0000-0000-0000-000000000000";
      setUserId(userId);

      const { data: turnosData } = await supabase
        .from("turnos")
        .select(`
          id,
          fecha,
          hora_inicio,
          empleado_id,
          empleados (
            id,
            nombre_completo,
            cargo
          ),
          cajas (nombre, ubicacion),
          aperturas (
            id,
            monto_inicial,
            cerrada
          )
        `)
        .eq("estado", "abierto")
        .order("created_at", { ascending: false });

      if (turnosData && turnosData.length > 0) {
        const turnoConApertura = turnosData.find((t: any) =>
          t.aperturas && t.aperturas.length > 0 && !t.aperturas[0].cerrada
        );

        if (turnoConApertura) {
          setAperturaActiva({
            turno_id: turnoConApertura.id,
            apertura_id: turnoConApertura.aperturas[0].id,
            monto_inicial: turnoConApertura.aperturas[0].monto_inicial,
            caja: turnoConApertura.cajas,
            fecha: turnoConApertura.fecha,
            hora_inicio: turnoConApertura.hora_inicio,
            empleado: turnoConApertura.empleados,
            empleado_id: turnoConApertura.empleado_id,
          });

          if (turnoConApertura.empleado_id) {
            setFormData(prev => ({
              ...prev,
              empleadoId: turnoConApertura.empleado_id
            }));
          }
        }
      }
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    } finally {
      setLoadingData(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!aperturaActiva) {
      toast({
        title: "Error",
        description: "No hay apertura activa para realizar arqueo",
        variant: "destructive",
      });
      return;
    }

    if (!formData.empleadoId) {
      toast({
        title: "Campo requerido",
        description: "Debes seleccionar un empleado",
        variant: "destructive",
      });
      return;
    }

    if (diferencia !== null && diferencia !== 0 && !formData.comentario.trim()) {
      toast({
        title: "Comentario requerido",
        description: "Cuando hay diferencia debes agregar un comentario explicativo.",
        variant: "destructive",
      });
      return;
    }

    setLoading(true);

    try {
      const montoContado = parseFloat(formData.montoContado);
      const montoFinal = parseFloat(formData.montoFinal);
      const totalPagosProveedores = pagosProveedores.reduce((sum, pago) => sum + (parseFloat(pago.valor) || 0), 0);
      const diferenciaFinal = diferencia || 0;

      const { data: arqueoData, error: arqueoError } = await supabase
        .from("arqueos")
        .insert({
          turno_id: aperturaActiva.turno_id,
          monto_contado: montoContado,
          monto_final: montoFinal,
          total_pagos_proveedores: totalPagosProveedores,
          diferencia: diferenciaFinal,
          comentario: formData.comentario || null,
        })
        .select()
        .single();

      if (arqueoError) throw arqueoError;

      for (const pago of pagosProveedores) {
        if (pago.proveedor && pago.valor) {
          await supabase.from("pagos_proveedores").insert({
            turno_id: aperturaActiva.turno_id,
            concepto: `${pago.tipo_documento} ${pago.numero_documento} - ${pago.proveedor}`,
            valor: parseFloat(pago.valor),
          });
        }
      }

      const { error: aperturaError } = await supabase
        .from("aperturas")
        .update({ cerrada: true })
        .eq("id", aperturaActiva.apertura_id);

      if (aperturaError) throw aperturaError;

      const { error: turnoError } = await supabase
        .from("turnos")
        .update({
          estado: "cerrado",
          hora_fin: new Date().toTimeString().slice(0, 5),
          empleado_id: formData.empleadoId
        })
        .eq("id", aperturaActiva.turno_id);

      if (turnoError) throw turnoError;

      toast({
        title: "Arqueo completado",
        description: "El turno ha sido cerrado correctamente",
      });

      navigate("/");
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  if (loadingData) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-bg">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-2 border-primary border-t-transparent mx-auto"></div>
          <p className="mt-4 text-foreground text-sm">Cargando datos...</p>
        </div>
      </div>
    );
  }

  if (!aperturaActiva) {
    return (
      <div className="min-h-screen bg-gradient-bg">
        <header className="border-b border-border/50 bg-card/90 backdrop-blur-md shadow-soft sticky top-0 z-50">
          <div className="container mx-auto px-6 py-6">
            <div className="flex items-center gap-4">
              <Button variant="ghost" size="icon" onClick={() => navigate("/")} className="hover:bg-muted">
                <ArrowLeft className="h-5 w-5" />
              </Button>
              <div>
                <h1 className="text-2xl font-semibold text-title tracking-tight">Arqueo de Caja</h1>
                <p className="text-sm text-muted-foreground mt-0.5">Cierre de turno</p>
              </div>
            </div>
          </div>
        </header>
        <main className="container mx-auto px-6 py-12 max-w-2xl">
          <Card className="shadow-medium border border-border/50">
            <CardContent className="pt-8">
              <Alert>
                <AlertCircle className="h-4 w-4" />
                <AlertDescription className="text-foreground">
                  No tienes ninguna apertura activa. Debes abrir una caja antes de realizar un arqueo.
                </AlertDescription>
              </Alert>
              <Button onClick={() => navigate("/apertura-caja")} className="mt-6 w-full h-11 bg-primary hover:bg-primary-hover shadow-primary">
                Ir a Apertura de Caja
              </Button>
            </CardContent>
          </Card>
        </main>
      </div>
    );
  }

  const requiereComentario = diferencia !== null && diferencia !== 0;
  const totalPagosProveedores = pagosProveedores.reduce((sum, pago) => sum + (parseFloat(pago.valor) || 0), 0);
  const montoEsperado = formData.montoFinal ? parseFloat(formData.montoFinal) - totalPagosProveedores : 0;

  return (
    <div className="min-h-screen bg-gradient-bg">
      <header className="border-b border-border/50 bg-card/90 backdrop-blur-md shadow-soft sticky top-0 z-50">
        <div className="container mx-auto px-6 py-6">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => navigate("/")} className="hover:bg-muted">
              <ArrowLeft className="h-5 w-5" />
            </Button>
            <div>
              <h1 className="text-2xl font-semibold text-title tracking-tight">Arqueo de Caja</h1>
              <p className="text-sm text-muted-foreground mt-0.5">Cierre de turno</p>
            </div>
          </div>
        </div>
      </header>

      <main className="container mx-auto px-6 py-8 max-w-5xl">
        <Card className="mb-6 shadow-medium border border-border/50">
          <CardHeader className="border-b border-border/30 bg-muted/30">
            <div className="flex items-start justify-between">
              <div>
                <CardTitle className="text-xl font-semibold text-title">Información del Turno Activo</CardTitle>
                <CardDescription className="text-sm text-muted-foreground mt-1">
                  Detalles de la apertura actual
                </CardDescription>
              </div>
              <div className="h-12 w-12 rounded-lg bg-accent/10 flex items-center justify-center">
                <Calculator className="h-6 w-6 text-accent" />
              </div>
            </div>
          </CardHeader>
          <CardContent className="pt-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
              <div className="p-3 rounded-lg bg-muted/40 border border-border/30">
                <p className="text-xs text-muted-foreground mb-1">Caja</p>
                <p className="text-sm font-medium text-foreground">{aperturaActiva.caja.nombre}</p>
              </div>
              <div className="p-3 rounded-lg bg-muted/40 border border-border/30">
                <p className="text-xs text-muted-foreground mb-1">Fecha</p>
                <p className="text-sm font-medium text-foreground">{new Date(aperturaActiva.fecha).toLocaleDateString()}</p>
              </div>
              <div className="p-3 rounded-lg bg-muted/40 border border-border/30">
                <p className="text-xs text-muted-foreground mb-1">Hora inicio</p>
                <p className="text-sm font-medium text-foreground">{aperturaActiva.hora_inicio}</p>
              </div>
              <div className="p-3 rounded-lg bg-primary/10 border border-primary/20">
                <p className="text-xs text-muted-foreground mb-1">Monto inicial</p>
                <p className="text-lg font-semibold text-primary">${aperturaActiva.monto_inicial.toFixed(2)}</p>
              </div>
            </div>

            <div className="space-y-4 pt-4 border-t border-border/30">
              <div className="space-y-2">
                <Label className="text-sm font-medium text-foreground flex items-center gap-2">
                  <User className="h-4 w-4 text-muted-foreground" />
                  Empleado Responsable
                </Label>
                <EmpleadoSelector
                  value={formData.empleadoId}
                  onChange={(value) => setFormData({ ...formData, empleadoId: value })}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="montoFinal" className="text-sm font-medium text-foreground flex items-center gap-2">
                  <DollarSign className="h-4 w-4 text-muted-foreground" />
                  Monto Final (USD)
                </Label>
                <div className="relative">
                  <span className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground text-sm">$</span>
                  <Input
                    id="montoFinal"
                    type="number"
                    step="0.01"
                    min="0"
                    value={formData.montoFinal}
                    onChange={(e) => setFormData({ ...formData, montoFinal: e.target.value })}
                    placeholder="0.00"
                    required
                    className="pl-7 h-10 border-border/50 focus:ring-2 focus:ring-primary/20"
                  />
                </div>
                <p className="text-xs text-muted-foreground">
                  Total de ventas realizadas en el turno
                </p>
              </div>

              <div className="space-y-2">
                <Label htmlFor="montoContado" className="text-sm font-medium text-foreground flex items-center gap-2">
                  <Calculator className="h-4 w-4 text-muted-foreground" />
                  Monto Contado (USD)
                </Label>
                <div className="relative">
                  <span className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground text-sm">$</span>
                  <Input
                    id="montoContado"
                    type="number"
                    step="0.01"
                    min="0"
                    value={formData.montoContado}
                    onChange={(e) => setFormData({ ...formData, montoContado: e.target.value })}
                    placeholder="0.00"
                    required
                    className="pl-7 h-10 border-border/50 focus:ring-2 focus:ring-primary/20"
                  />
                </div>
                <p className="text-xs text-muted-foreground">
                  Efectivo físico contado por el administrador
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="mb-6 shadow-medium border border-border/50">
          <CardHeader className="border-b border-border/30 bg-muted/30">
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="text-lg font-semibold text-title flex items-center gap-2">
                  <FileText className="h-5 w-5 text-muted-foreground" />
                  Pagos a Proveedores
                </CardTitle>
                <CardDescription className="text-sm text-muted-foreground mt-1">
                  Registra los pagos realizados durante el turno
                </CardDescription>
              </div>
              <Button type="button" size="sm" onClick={agregarPagoProveedor} className="h-9 shadow-soft">
                <Plus className="h-4 w-4 mr-1" />
                Agregar Pago
              </Button>
            </div>
          </CardHeader>
          <CardContent className="pt-6">
            {pagosProveedores.length === 0 ? (
              <div className="text-center py-12 text-muted-foreground">
                <FileText className="h-12 w-12 mx-auto mb-3 opacity-30" />
                <p className="text-sm">No hay pagos registrados</p>
              </div>
            ) : (
              <div className="overflow-x-auto -mx-6">
                <div className="inline-block min-w-full align-middle px-6">
                  <Table>
                    <TableHeader>
                      <TableRow className="border-border/50">
                        <TableHead className="text-xs font-medium text-muted-foreground">Proveedor</TableHead>
                        <TableHead className="text-xs font-medium text-muted-foreground">Documento</TableHead>
                        <TableHead className="text-xs font-medium text-muted-foreground">Número</TableHead>
                        <TableHead className="text-xs font-medium text-muted-foreground">Valor</TableHead>
                        <TableHead className="w-[50px]"></TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {pagosProveedores.map((pago) => (
                        <TableRow key={pago.id} className="border-border/50">
                          <TableCell className="py-3">
                            <Input
                              value={pago.proveedor}
                              onChange={(e) => actualizarPagoProveedor(pago.id, "proveedor", e.target.value)}
                              placeholder="Nombre del proveedor"
                              className="h-9 text-sm border-border/50"
                            />
                          </TableCell>
                          <TableCell className="py-3">
                            <Select
                              value={pago.tipo_documento}
                              onValueChange={(value) => actualizarPagoProveedor(pago.id, "tipo_documento", value)}
                            >
                              <SelectTrigger className="h-9 text-sm border-border/50">
                                <SelectValue />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectItem value="Factura">Factura</SelectItem>
                                <SelectItem value="Nota de venta">Nota de venta</SelectItem>
                                <SelectItem value="Doc. no autorizado">Doc. no autorizado</SelectItem>
                                <SelectItem value="Devolución">Devolución</SelectItem>
                                <SelectItem value="Recepción">Recepción</SelectItem>
                              </SelectContent>
                            </Select>
                          </TableCell>
                          <TableCell className="py-3">
                            <Input
                              value={pago.numero_documento}
                              onChange={(e) => actualizarPagoProveedor(pago.id, "numero_documento", e.target.value)}
                              placeholder="Número"
                              className="h-9 text-sm border-border/50"
                            />
                          </TableCell>
                          <TableCell className="py-3">
                            <div className="relative">
                              <span className="absolute left-2 top-1/2 -translate-y-1/2 text-xs text-muted-foreground">$</span>
                              <Input
                                type="number"
                                step="0.01"
                                value={pago.valor}
                                onChange={(e) => actualizarPagoProveedor(pago.id, "valor", e.target.value)}
                                placeholder="0.00"
                                className="pl-5 h-9 text-sm border-border/50"
                              />
                            </div>
                          </TableCell>
                          <TableCell className="py-3">
                            <Button
                              type="button"
                              variant="ghost"
                              size="icon"
                              onClick={() => eliminarPagoProveedor(pago.id)}
                              className="h-9 w-9 text-destructive hover:text-destructive hover:bg-destructive/10"
                            >
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              </div>
            )}
          </CardContent>
        </Card>

        {diferencia !== null && formData.montoFinal && formData.montoContado && (
          <Card className={`mb-6 shadow-medium border ${diferencia < 0 ? 'border-destructive/50 bg-destructive/5' : diferencia > 0 ? 'border-warning/50 bg-warning/5' : 'border-success/50 bg-success/5'}`}>
            <CardContent className="pt-6">
              <div className="space-y-4">
                <div className="grid grid-cols-3 gap-3 text-sm">
                  <div className="p-3 rounded-lg bg-muted/40 border border-border/30">
                    <p className="text-xs text-muted-foreground mb-1">Monto Final</p>
                    <p className="font-semibold text-foreground">${parseFloat(formData.montoFinal).toFixed(2)}</p>
                  </div>
                  <div className="p-3 rounded-lg bg-muted/40 border border-border/30">
                    <p className="text-xs text-muted-foreground mb-1">Pagos Proveedores</p>
                    <p className="font-semibold text-foreground">-${totalPagosProveedores.toFixed(2)}</p>
                  </div>
                  <div className="p-3 rounded-lg bg-primary/10 border border-primary/20">
                    <p className="text-xs text-muted-foreground mb-1">Monto Esperado</p>
                    <p className="font-semibold text-primary">${montoEsperado.toFixed(2)}</p>
                  </div>
                </div>
                <div className="flex items-center justify-between pt-2 border-t border-border/30">
                  <div>
                    <p className="text-sm font-medium text-foreground mb-1">Diferencia Calculada</p>
                    <p className="text-xs text-muted-foreground">
                      {diferencia < 0 
                        ? `Faltan $${Math.abs(diferencia).toFixed(2)} (Monto Contado menor al Esperado)`
                        : diferencia > 0 
                        ? `Sobran $${diferencia.toFixed(2)} (Monto Contado mayor al Esperado)`
                        : 'Cuadra perfectamente'}
                    </p>
                  </div>
                  <div className={`text-2xl font-bold ${diferencia < 0 ? 'text-destructive' : diferencia > 0 ? 'text-warning' : 'text-success'}`}>
                    ${Math.abs(diferencia).toFixed(2)}
                    <span className="text-sm ml-1">{diferencia < 0 ? 'faltante' : diferencia > 0 ? 'sobrante' : 'exacto'}</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        <Card className="mb-6 shadow-medium border border-border/50">
          <CardContent className="pt-6">
            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="space-y-2">
                <Label htmlFor="comentario" className="text-sm font-medium text-foreground">
                  Comentario {requiereComentario && <span className="text-destructive">*</span>}
                </Label>
                <Textarea
                  id="comentario"
                  value={formData.comentario}
                  onChange={(e) => setFormData({ ...formData, comentario: e.target.value })}
                  placeholder="Observaciones sobre el arqueo..."
                  rows={3}
                  className="resize-none border-border/50 focus:ring-2 focus:ring-primary/20"
                />
                {requiereComentario && (
                  <p className="text-xs text-destructive">
                    Existe una diferencia. Debes agregar un comentario explicativo.
                  </p>
                )}
              </div>

              <div className="flex gap-3 pt-4 border-t border-border/30">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => navigate("/")}
                  className="flex-1 h-11"
                >
                  Cancelar
                </Button>
                <Button
                  type="submit"
                  disabled={loading}
                  className="flex-1 h-11 bg-success hover:bg-success-hover shadow-soft"
                >
                  {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                  Completar Arqueo
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      </main>
    </div>
  );
};

export default ArqueoCaja;