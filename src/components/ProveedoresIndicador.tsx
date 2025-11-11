import { useState, useEffect } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { useToast } from "@/hooks/use-toast";
import { DollarSign, Loader2, AlertCircle } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";

interface PagoProveedor {
  id: string;
  concepto: string;
  valor: number;
  turno_id: string;
  fecha_hora: string;
  created_at: string;
}

export const ProveedoresIndicador = () => {
  const [pagos, setPagos] = useState<PagoProveedor[]>([]);
  const [loading, setLoading] = useState(true);
  const [totalPagado, setTotalPagado] = useState(0);
  const [modalOpen, setModalOpen] = useState(false);
  const { toast } = useToast();

  useEffect(() => {
    loadPagos();
  }, []);

  const loadPagos = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from("pagos_proveedores")
        .select("*")
        .order("created_at", { ascending: false });

      if (error) throw error;

      if (data) {
        setPagos(data);
        const total = data.reduce((sum, pago) => sum + (pago.valor || 0), 0);
        setTotalPagado(total);
      }
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

  const agruparPorConcepto = () => {
    const agrupado: { [key: string]: { monto: number; cantidad: number; pagos: PagoProveedor[] } } = {};

    pagos.forEach((pago) => {
      const concepto = pago.concepto || "Sin concepto";
      if (!agrupado[concepto]) {
        agrupado[concepto] = { monto: 0, cantidad: 0, pagos: [] };
      }
      agrupado[concepto].monto += pago.valor || 0;
      agrupado[concepto].cantidad += 1;
      agrupado[concepto].pagos.push(pago);
    });

    return agrupado;
  };

  const conceptosAgrupados = agruparPorConcepto();

  return (
    <>
      <Card
        className="group relative overflow-hidden hover:shadow-large transition-all duration-500 cursor-pointer border-2 border-accent/30 hover:border-accent hover:-translate-y-2 bg-card hover:bg-accent/10 animate-scale-in"
        onClick={() => setModalOpen(true)}
      >
        <div className="absolute inset-0 bg-accent opacity-0 group-hover:opacity-5 transition-opacity duration-500" />
        <CardHeader className="text-center p-8 relative z-10">
          <div className="mx-auto mb-6 w-20 h-20 rounded-2xl bg-accent flex items-center justify-center shadow-accent transition-all duration-500 group-hover:scale-110 group-hover:rotate-6">
            <DollarSign className="h-10 w-10 text-white" />
          </div>
          <CardTitle className="text-2xl mb-4 text-title font-bold group-hover:scale-105 transition-transform duration-300">
            Pagos a Proveedores
          </CardTitle>
          {loading ? (
            <div className="flex items-center justify-center py-4">
              <Loader2 className="h-5 w-5 animate-spin text-accent" />
            </div>
          ) : (
            <div className="space-y-2">
              <p className="text-4xl font-bold text-accent">
                ${totalPagado.toFixed(2)}
              </p>
              <p className="text-sm text-muted-foreground font-medium">
                {pagos.length} transacciones | {Object.keys(conceptosAgrupados).length} conceptos
              </p>
            </div>
          )}
        </CardHeader>
        <div className="absolute -bottom-2 -right-2 w-24 h-24 bg-accent rounded-full opacity-0 group-hover:opacity-10 blur-2xl transition-all duration-500" />
      </Card>

      <Dialog open={modalOpen} onOpenChange={setModalOpen}>
        <DialogContent className="max-w-4xl max-h-[80vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="text-2xl">Detalle de Pagos a Proveedores</DialogTitle>
            <DialogDescription>
              Total pagado: <span className="text-xl font-bold text-accent">${totalPagado.toFixed(2)}</span>
            </DialogDescription>
          </DialogHeader>

          {pagos.length === 0 ? (
            <Alert>
              <AlertCircle className="h-4 w-4" />
              <AlertDescription>No hay pagos registrados a proveedores</AlertDescription>
            </Alert>
          ) : (
            <div className="space-y-6">
              {Object.entries(conceptosAgrupados).map(([nombreConcepto, datos]) => (
                <div key={nombreConcepto} className="space-y-3 border rounded-lg p-4 bg-muted/30">
                  <div className="flex items-center justify-between">
                    <h3 className="text-lg font-semibold text-foreground">{nombreConcepto}</h3>
                    <div className="flex items-center gap-3">
                      <Badge variant="secondary">
                        {datos.cantidad} {datos.cantidad === 1 ? "pago" : "pagos"}
                      </Badge>
                      <span className="text-xl font-bold text-accent">
                        ${datos.monto.toFixed(2)}
                      </span>
                    </div>
                  </div>

                  <div className="overflow-x-auto">
                    <Table className="text-sm">
                      <TableHeader>
                        <TableRow className="border-border/50">
                          <TableHead className="text-xs font-semibold">Concepto</TableHead>
                          <TableHead className="text-xs font-semibold text-right">Valor</TableHead>
                          <TableHead className="text-xs font-semibold">Fecha y Hora</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {datos.pagos.map((pago) => (
                          <TableRow key={pago.id} className="border-border/30">
                            <TableCell className="text-xs font-medium">{pago.concepto}</TableCell>
                            <TableCell className="text-xs font-semibold text-right text-foreground">
                              ${pago.valor.toFixed(2)}
                            </TableCell>
                            <TableCell className="text-xs text-muted-foreground">
                              {new Date(pago.fecha_hora).toLocaleString("es-ES", {
                                year: "numeric",
                                month: "2-digit",
                                day: "2-digit",
                                hour: "2-digit",
                                minute: "2-digit"
                              })}
                            </TableCell>
                          </TableRow>
                        ))}
                      </TableBody>
                    </Table>
                  </div>
                </div>
              ))}
            </div>
          )}
        </DialogContent>
      </Dialog>
    </>
  );
};
