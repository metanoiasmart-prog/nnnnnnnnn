import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { useToast } from "@/hooks/use-toast";
import { ArrowLeft, Loader2, AlertCircle, Send, DollarSign, MapPin, User } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";

const TrasladoEfectivo = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [loading, setLoading] = useState(false);
  const [loadingData, setLoadingData] = useState(true);
  const [ultimoArqueo, setUltimoArqueo] = useState<any>(null);
  const [cajaDestino, setCajaDestino] = useState<any>(null);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      const userId = "00000000-0000-0000-0000-000000000000";

      const { data: arqueosData } = await supabase
        .from("arqueos")
        .select(`
          id,
          monto_contado,
          monto_final,
          diferencia,
          created_at,
          turno_id,
          turnos!inner (
            id,
            empleado_id,
            empleados (
              id,
              nombre_completo,
              cargo
            ),
            cajas!inner (
              id,
              nombre,
              tipo
            )
          ),
          traslados (id)
        `)
        .is("traslados.id", null)
        .order("created_at", { ascending: false })
        .limit(1);

      if (arqueosData && arqueosData.length > 0) {
        const arqueo = arqueosData[0];
        setUltimoArqueo({
          id: arqueo.id,
          monto: arqueo.monto_contado,
          monto_final: arqueo.monto_final,
          diferencia: arqueo.diferencia,
          fecha_hora: arqueo.created_at,
          caja_origen: arqueo.turnos.cajas,
          empleado: arqueo.turnos.empleados,
        });

        const { data: cajaPrincipal } = await supabase
          .from("cajas")
          .select("*")
          .eq("tipo", "principal")
          .maybeSingle();

        setCajaDestino(cajaPrincipal);
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

  const handleCerrarCajaYConfirmarTraslado = async () => {
    if (!ultimoArqueo || !cajaDestino) return;

    setLoading(true);
    try {
      const userId = "00000000-0000-0000-0000-000000000000";

      const { data: trasladoData, error: trasladoError } = await supabase
        .from("traslados")
        .insert({
          turno_id: ultimoArqueo.caja_origen.id,
          empleado_envia_id: ultimoArqueo.empleado.id,
          monto: ultimoArqueo.monto,
          estado: "en_transito",
          fecha_hora: new Date().toISOString(),
        })
        .select()
        .single();

      if (trasladoError) throw trasladoError;

      // Crear automáticamente el registro en recepciones
      const { error: recepcionError } = await supabase
        .from("recepciones")
        .insert({
          traslado_id: trasladoData.id,
          empleado_recibe_id: ultimoArqueo.empleado.id,
          monto_recibido: 0,
          diferencia: 0,
          fecha_hora: new Date().toISOString(),
          comentario: null,
        });

      if (recepcionError) throw recepcionError;

      toast({
        title: "Caja cerrada y traslado confirmado",
        description: "El efectivo está en tránsito a Caja Principal",
      });

      // Limpiar los datos del módulo después de confirmar el traslado
      setUltimoArqueo(null);
      setCajaDestino(null);

      // Navegar al dashboard para que pueda abrir nueva caja
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

  if (!ultimoArqueo) {
    return (
      <div className="min-h-screen bg-gradient-bg">
        <header className="border-b border-border/50 bg-card/90 backdrop-blur-md shadow-soft sticky top-0 z-50">
          <div className="container mx-auto px-6 py-6">
            <div className="flex items-center gap-4">
              <Button variant="ghost" size="icon" onClick={() => navigate("/")} className="hover:bg-muted">
                <ArrowLeft className="h-5 w-5" />
              </Button>
              <div>
                <h1 className="text-2xl font-semibold text-title tracking-tight">Traslado de Efectivo</h1>
                <p className="text-sm text-muted-foreground mt-0.5">Enviar a Caja Principal</p>
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
                  No hay arqueos pendientes de traslado. Debes realizar un arqueo de caja antes de crear un traslado.
                </AlertDescription>
              </Alert>
              <Button onClick={() => navigate("/arqueo-caja")} className="mt-6 w-full h-11 bg-primary hover:bg-primary-hover shadow-primary">
                Ir a Arqueo de Caja
              </Button>
            </CardContent>
          </Card>
        </main>
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
              <h1 className="text-2xl font-semibold text-title tracking-tight">Traslado de Efectivo</h1>
              <p className="text-sm text-muted-foreground mt-0.5">Enviar a Caja Principal</p>
            </div>
          </div>
        </div>
      </header>

      <main className="container mx-auto px-6 py-8 max-w-3xl">
        <Card className="mb-6 shadow-medium border border-border/50">
          <CardHeader className="border-b border-border/30 bg-muted/30">
            <div className="flex items-start justify-between">
              <div>
                <CardTitle className="text-xl font-semibold text-title">Último Arqueo Realizado</CardTitle>
                <CardDescription className="text-sm text-muted-foreground mt-1">
                  Este efectivo será trasladado a la Caja Principal
                </CardDescription>
              </div>
              <div className="h-12 w-12 rounded-lg bg-accent/10 flex items-center justify-center">
                <Send className="h-6 w-6 text-accent" />
              </div>
            </div>
          </CardHeader>
          <CardContent className="pt-6">
            <div className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="p-3 rounded-lg bg-muted/40 border border-border/30">
                  <p className="text-xs text-muted-foreground mb-1 flex items-center gap-1">
                    <MapPin className="h-3 w-3" />
                    Caja Origen
                  </p>
                  <p className="text-sm font-medium text-foreground">{ultimoArqueo.caja_origen.nombre}</p>
                </div>
                <div className="p-3 rounded-lg bg-muted/40 border border-border/30">
                  <p className="text-xs text-muted-foreground mb-1 flex items-center gap-1">
                    <MapPin className="h-3 w-3" />
                    Caja Destino
                  </p>
                  <p className="text-sm font-medium text-foreground">{cajaDestino?.nombre}</p>
                </div>
                <div className="p-3 rounded-lg bg-muted/40 border border-border/30">
                  <p className="text-xs text-muted-foreground mb-1 flex items-center gap-1">
                    <User className="h-3 w-3" />
                    Empleado
                  </p>
                  <p className="text-sm font-medium text-foreground">
                    {ultimoArqueo.empleado ? `${ultimoArqueo.empleado.nombre_completo}` : "No asignado"}
                  </p>
                  {ultimoArqueo.empleado?.cargo && (
                    <p className="text-xs text-muted-foreground">{ultimoArqueo.empleado.cargo}</p>
                  )}
                </div>
                <div className="p-3 rounded-lg bg-muted/40 border border-border/30">
                  <p className="text-xs text-muted-foreground mb-1">Fecha y hora</p>
                  <p className="text-sm font-medium text-foreground">
                    {new Date(ultimoArqueo.fecha_hora).toLocaleString()}
                  </p>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4 pt-2">
                <div className="p-3 rounded-lg bg-primary/10 border border-primary/20">
                  <p className="text-xs text-muted-foreground mb-1">Monto Final</p>
                  <p className="text-base font-semibold text-primary">${ultimoArqueo.monto_final?.toFixed(2) || "0.00"}</p>
                </div>
                <div className="p-3 rounded-lg bg-muted/40 border border-border/30">
                  <p className="text-xs text-muted-foreground mb-1">Diferencia Arqueo</p>
                  <p className={`text-base font-semibold ${ultimoArqueo.diferencia < 0 ? 'text-destructive' : ultimoArqueo.diferencia > 0 ? 'text-warning' : 'text-success'}`}>
                    ${ultimoArqueo.diferencia?.toFixed(2) || "0.00"}
                  </p>
                </div>
              </div>

              <div className="p-4 rounded-lg bg-primary/10 border border-primary/20">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-foreground mb-1 flex items-center gap-2">
                      <DollarSign className="h-4 w-4 text-primary" />
                      Monto a Trasladar
                    </p>
                    <p className="text-xs text-muted-foreground">
                      Efectivo contado en arqueo
                    </p>
                  </div>
                  <p className="text-3xl font-bold text-primary">
                    ${ultimoArqueo.monto.toFixed(2)}
                  </p>
                </div>
              </div>

              {ultimoArqueo.diferencia !== 0 && (
                <Alert variant={Math.abs(ultimoArqueo.diferencia) > 2 ? "destructive" : "default"}>
                  <AlertCircle className="h-4 w-4" />
                  <AlertDescription>
                    Diferencia en arqueo: ${ultimoArqueo.diferencia.toFixed(2)}
                  </AlertDescription>
                </Alert>
              )}
            </div>
          </CardContent>
        </Card>

        <Card className="shadow-medium border border-border/50">
          <CardHeader className="border-b border-border/30 bg-muted/30">
            <CardTitle className="text-lg font-semibold text-title">Confirmar Traslado</CardTitle>
            <CardDescription className="text-sm text-muted-foreground mt-1">
              El traslado quedará en estado "En Tránsito" hasta ser recibido en Caja Principal
            </CardDescription>
          </CardHeader>
          <CardContent className="pt-6">
            <Alert className="mb-6">
              <AlertCircle className="h-4 w-4" />
              <AlertDescription className="text-sm text-foreground">
                Asegúrate de colocar el efectivo en el sobre/bolsa correspondiente antes de confirmar el traslado.
              </AlertDescription>
            </Alert>

            <div className="flex gap-3">
              <Button
                variant="outline"
                onClick={() => navigate("/")}
                className="flex-1 h-11"
              >
                Cancelar
              </Button>
              <Button
                onClick={handleCerrarCajaYConfirmarTraslado}
                disabled={loading}
                className="flex-1 h-11 bg-success hover:bg-success-hover shadow-soft"
              >
                {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                Cerrar Caja y Confirmar Traslado
              </Button>
            </div>
          </CardContent>
        </Card>
      </main>
    </div>
  );
};

export default TrasladoEfectivo;