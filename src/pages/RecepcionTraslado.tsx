import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { useToast } from "@/hooks/use-toast";
import { ArrowLeft, CheckCircle, Loader2, AlertCircle, Clock, DollarSign, User, MapPin } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { ProveedoresIndicador } from "@/components/ProveedoresIndicador";

const RecepcionTraslado = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [loading, setLoading] = useState(false);
  const [loadingData, setLoadingData] = useState(true);
  const [trasladosPendientes, setTrasladosPendientes] = useState<any[]>([]);
  const [trasladoSeleccionado, setTrasladoSeleccionado] = useState<any>(null);

  const [formData, setFormData] = useState({
    montoRecibido: "",
    comentario: "",
  });

  const [diferencia, setDiferencia] = useState<number | null>(null);

  useEffect(() => {
    loadData();
  }, []);

  useEffect(() => {
    if (formData.montoRecibido && trasladoSeleccionado) {
      const recibido = parseFloat(formData.montoRecibido);
      const esperado = trasladoSeleccionado.monto;
      setDiferencia(recibido - esperado);
    } else {
      setDiferencia(null);
    }
  }, [formData.montoRecibido, trasladoSeleccionado]);

  const loadData = async () => {
    try {
      const { data: trasladosData, error: trasladosError } = await supabase
        .from("traslados")
        .select(`
          id,
          monto,
          estado,
          fecha_hora,
          turno_id,
          empleado_envia_id,
          turnos!inner(
            id,
            cajas(nombre, ubicacion),
            empleados(nombre_completo, cargo)
          ),
          recepciones(
            id,
            monto_recibido,
            diferencia,
            comentario
          )
        `)
        .in("estado", ["en_transito", "recibido", "observado"])
        .order("fecha_hora", { ascending: false });

      if (trasladosError) throw trasladosError;

      if (trasladosData) {
        setTrasladosPendientes(trasladosData);
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

  const calcularTiempoTransito = (fechaEnvio: string) => {
    const envio = new Date(fechaEnvio);
    const ahora = new Date();
    const minutos = Math.floor((ahora.getTime() - envio.getTime()) / 60000);
    return minutos;
  };

  const handleRecibir = async () => {
    if (!trasladoSeleccionado) return;

    const requiereComentario = diferencia !== null && Math.abs(diferencia) !== 0;
    if (requiereComentario && !formData.comentario.trim()) {
      toast({
        title: "Comentario requerido",
        description: "Debes agregar un comentario cuando hay diferencia en el monto recibido.",
        variant: "destructive",
      });
      return;
    }

    setLoading(true);
    try {
      const montoRecibido = parseFloat(formData.montoRecibido);
      const diferenciaFinal = montoRecibido - trasladoSeleccionado.monto;

      const recepcionId = trasladoSeleccionado.recepciones?.[0]?.id;
      
      if (recepcionId) {
        const { error: recepcionError } = await supabase
          .from("recepciones")
          .update({
            empleado_recibe_id: trasladoSeleccionado.empleado_envia_id,
            monto_recibido: montoRecibido,
            diferencia: diferenciaFinal,
            comentario: formData.comentario || null,
            fecha_hora: new Date().toISOString(),
          })
          .eq("id", recepcionId);

        if (recepcionError) throw recepcionError;
      } else {
        const { error: recepcionError } = await supabase
          .from("recepciones")
          .insert({
            traslado_id: trasladoSeleccionado.id,
            empleado_recibe_id: trasladoSeleccionado.empleado_envia_id,
            monto_recibido: montoRecibido,
            diferencia: diferenciaFinal,
            fecha_hora: new Date().toISOString(),
            comentario: formData.comentario || null,
          });

        if (recepcionError) throw recepcionError;
      }

      const nuevoEstado = diferenciaFinal === 0 ? "recibido" : "observado";
      const { error: trasladoError } = await supabase
        .from("traslados")
        .update({ estado: nuevoEstado })
        .eq("id", trasladoSeleccionado.id);

      if (trasladoError) throw trasladoError;

      toast({
        title: "¡Traslado recibido!",
        description: `Estado: ${nuevoEstado === "recibido" ? "Recibido" : "Observado (con diferencia)"}`,
      });

      setFormData({ montoRecibido: "", comentario: "" });
      setTrasladoSeleccionado(null);
      await loadData();
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
          <p className="mt-4 text-foreground text-sm">Cargando traslados...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-bg">
      <header className="border-b border-border/50 bg-card/90 backdrop-blur-md shadow-soft sticky top-0 z-50">
        <div className="container mx-auto px-6 py-6">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => navigate("/")} className="hover:bg-muted">
              <ArrowLeft className="h-5 w-5" />
            </Button>
            <div>
              <h1 className="text-2xl font-semibold text-title tracking-tight">Recepción de Traslado</h1>
              <p className="text-sm text-muted-foreground mt-0.5">Caja Principal</p>
            </div>
          </div>
        </div>
      </header>

      <main className="container mx-auto px-6 py-8 max-w-5xl">
        {trasladosPendientes.length === 0 ? (
          <Card className="shadow-medium border border-border/50">
            <CardContent className="pt-8">
              <Alert>
                <AlertCircle className="h-4 w-4" />
                <AlertDescription className="text-foreground">
                  No hay traslados pendientes de recepción en este momento.
                </AlertDescription>
              </Alert>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-6">
            <div>
              <h2 className="text-xl font-semibold text-title mb-4">Traslados</h2>
              <div className="grid gap-4">
                {trasladosPendientes.map((traslado) => {
                  const minutosTransito = calcularTiempoTransito(traslado.fecha_hora);
                  const alertaTransito = minutosTransito > 30;
                  const empleado = traslado.turnos?.empleados;
                  const cajaOrigen = traslado.turnos?.cajas;
                  const esEditable = traslado.estado === "en_transito";
                  const recepcion = traslado.recepciones?.[0];

                  return (
                    <div key={traslado.id} className="space-y-4">
                      <Card
                        className={`transition-all border ${
                          trasladoSeleccionado?.id === traslado.id
                            ? "ring-2 ring-primary border-primary shadow-primary"
                            : "border-border/50 hover:shadow-medium hover:border-primary/30"
                        } ${esEditable ? "cursor-pointer" : ""}`}
                        onClick={() => {
                          if (esEditable) {
                            setTrasladoSeleccionado(traslado);
                            setFormData({ montoRecibido: traslado.monto.toString(), comentario: "" });
                          }
                        }}
                      >
                      <CardHeader className="pb-4">
                        <div className="flex justify-between items-start">
                          <div>
                            <CardTitle className="text-lg font-semibold text-title flex items-center gap-2">
                              <MapPin className="h-4 w-4 text-muted-foreground" />
                              {cajaOrigen?.nombre || 'N/A'}
                            </CardTitle>
                            <CardDescription className="text-sm text-muted-foreground mt-1">
                              Enviado: {new Date(traslado.fecha_hora).toLocaleString()}
                            </CardDescription>
                          </div>
                          <div className="flex gap-2">
                            {traslado.estado === "en_transito" && (
                              <>
                                <Badge variant="secondary" className="h-7">
                                  <Clock className="h-3 w-3 mr-1" />
                                  {minutosTransito} min
                                </Badge>
                                {alertaTransito && (
                                  <Badge variant="destructive" className="h-7">¡Alerta!</Badge>
                                )}
                              </>
                            )}
                            {traslado.estado === "recibido" && (
                              <Badge variant="secondary" className="h-7 bg-success/20 text-success border-success/30">
                                Recibido
                              </Badge>
                            )}
                            {traslado.estado === "observado" && (
                              <Badge variant="destructive" className="h-7">
                                Observado
                              </Badge>
                            )}
                          </div>
                        </div>
                      </CardHeader>
                      <CardContent>
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-4">
                          <div className="p-2.5 rounded-lg bg-muted/40 border border-border/30">
                            <p className="text-xs text-muted-foreground mb-0.5 flex items-center gap-1">
                              <User className="h-3 w-3" />
                              Empleado
                            </p>
                            <p className="text-sm font-medium text-foreground truncate">
                              {empleado ? empleado.nombre_completo : "N/A"}
                            </p>
                          </div>
                          <div className="p-2.5 rounded-lg bg-muted/40 border border-border/30">
                            <p className="text-xs text-muted-foreground mb-0.5">Cargo</p>
                            <p className="text-sm font-medium text-foreground">{empleado?.cargo || "N/A"}</p>
                          </div>
                          <div className="p-2.5 rounded-lg bg-muted/40 border border-border/30">
                            <p className="text-xs text-muted-foreground mb-0.5">Origen</p>
                            <p className="text-sm font-medium text-foreground">{cajaOrigen?.ubicacion || "N/A"}</p>
                          </div>
                          <div className="p-2.5 rounded-lg bg-muted/40 border border-border/30">
                            <p className="text-xs text-muted-foreground mb-0.5">Tiempo en tránsito</p>
                            <p className="text-sm font-medium text-foreground">{minutosTransito} minutos</p>
                          </div>
                        </div>
                        <div className="p-3 rounded-lg bg-success/10 border border-success/20">
                          <div className="flex items-center justify-between">
                            <div className="flex items-center gap-2">
                              <DollarSign className="h-5 w-5 text-success" />
                              <span className="text-sm font-medium text-foreground">Monto a recibir</span>
                            </div>
                            <span className="text-2xl font-bold text-success">
                              ${traslado.monto.toFixed(2)}
                            </span>
                          </div>
                        </div>

                        {!esEditable && recepcion && (
                          <div className="mt-4 p-3 rounded-lg bg-muted/30 border border-border/30">
                            <p className="text-xs font-semibold text-foreground mb-2">Información de Recepción</p>
                            <div className="grid grid-cols-2 gap-2">
                              <div>
                                <p className="text-xs text-muted-foreground">Monto Recibido</p>
                                <p className="text-sm font-medium text-foreground">${recepcion.monto_recibido?.toFixed(2) || "0.00"}</p>
                              </div>
                              <div>
                                <p className="text-xs text-muted-foreground">Diferencia</p>
                                <p className={`text-sm font-medium ${
                                  recepcion.diferencia === 0 ? "text-success" : "text-destructive"
                                }`}>
                                  ${recepcion.diferencia?.toFixed(2) || "0.00"}
                                </p>
                              </div>
                            </div>
                            {recepcion.comentario && (
                              <div className="mt-2">
                                <p className="text-xs text-muted-foreground">Comentario</p>
                                <p className="text-sm text-foreground">{recepcion.comentario}</p>
                              </div>
                            )}
                          </div>
                        )}
                      </CardContent>

                      {esEditable && trasladoSeleccionado?.id === traslado.id && (
                        <CardContent className="pt-0 border-t border-border/30">
                          <div className="pt-6 space-y-6">
                            <div className="space-y-2">
                              <Label htmlFor="montoRecibido" className="text-sm font-medium text-foreground flex items-center gap-2">
                                <DollarSign className="h-4 w-4 text-muted-foreground" />
                                Monto Recibido (USD)
                              </Label>
                              <div className="relative">
                                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground text-sm">$</span>
                                <Input
                                  id="montoRecibido"
                                  type="number"
                                  step="0.01"
                                  min="0"
                                  value={formData.montoRecibido}
                                  onChange={(e) => setFormData({ ...formData, montoRecibido: e.target.value })}
                                  placeholder="0.00"
                                  required
                                  className="pl-7 h-10 border-border/50 focus:ring-2 focus:ring-primary/20"
                                />
                              </div>
                            </div>

                            {diferencia !== null && diferencia !== 0 && (
                              <Alert variant="destructive">
                                <AlertCircle className="h-4 w-4" />
                                <AlertDescription>
                                  <strong>Diferencia detectada: ${diferencia.toFixed(2)}</strong>
                                  <p className="mt-1 text-sm">
                                    El traslado será marcado como "Observado". Debes agregar un comentario.
                                  </p>
                                </AlertDescription>
                              </Alert>
                            )}

                            <div className="space-y-2">
                              <Label htmlFor="comentario" className="text-sm font-medium text-foreground">
                                Comentario {diferencia !== 0 && diferencia !== null && <span className="text-destructive">*</span>}
                              </Label>
                              <Textarea
                                id="comentario"
                                value={formData.comentario}
                                onChange={(e) => setFormData({ ...formData, comentario: e.target.value })}
                                placeholder="Observaciones sobre la recepción..."
                                rows={3}
                                className="resize-none border-border/50 focus:ring-2 focus:ring-primary/20"
                              />
                            </div>

                            <div className="flex gap-3 pt-4 border-t border-border/30">
                              <Button
                                variant="outline"
                                onClick={() => {
                                  setTrasladoSeleccionado(null);
                                  setFormData({ montoRecibido: "", comentario: "" });
                                }}
                                className="flex-1 h-11"
                              >
                                Cancelar
                              </Button>
                              <Button
                                onClick={handleRecibir}
                                disabled={loading}
                                className="flex-1 h-11 bg-success hover:bg-success-hover shadow-soft"
                              >
                                {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                                Registrar Recepción
                              </Button>
                            </div>
                          </div>
                        </CardContent>
                      )}
                    </Card>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
};

export default RecepcionTraslado;