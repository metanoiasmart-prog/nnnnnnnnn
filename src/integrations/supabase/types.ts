export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "13.0.5"
  }
  public: {
    Tables: {
      aperturas: {
        Row: {
          cerrada: boolean
          created_at: string
          id: string
          monto_inicial: number
          observaciones: string | null
          turno_id: string
          updated_at: string
        }
        Insert: {
          cerrada?: boolean
          created_at?: string
          id?: string
          monto_inicial?: number
          observaciones?: string | null
          turno_id: string
          updated_at?: string
        }
        Update: {
          cerrada?: boolean
          created_at?: string
          id?: string
          monto_inicial?: number
          observaciones?: string | null
          turno_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "aperturas_turno_id_fkey"
            columns: ["turno_id"]
            isOneToOne: false
            referencedRelation: "turnos"
            referencedColumns: ["id"]
          },
        ]
      }
      arqueos: {
        Row: {
          created_at: string
          diferencia: number
          id: string
          monto_contado: number
          monto_final: number
          monto_sistema: number
          observaciones: string | null
          turno_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          diferencia?: number
          id?: string
          monto_contado?: number
          monto_final?: number
          monto_sistema?: number
          observaciones?: string | null
          turno_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          diferencia?: number
          id?: string
          monto_contado?: number
          monto_final?: number
          monto_sistema?: number
          observaciones?: string | null
          turno_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "arqueos_turno_id_fkey"
            columns: ["turno_id"]
            isOneToOne: false
            referencedRelation: "turnos"
            referencedColumns: ["id"]
          },
        ]
      }
      cajas: {
        Row: {
          activa: boolean
          created_at: string
          id: string
          nombre: string
          tipo: string
          ubicacion: string
          updated_at: string
        }
        Insert: {
          activa?: boolean
          created_at?: string
          id?: string
          nombre: string
          tipo?: string
          ubicacion: string
          updated_at?: string
        }
        Update: {
          activa?: boolean
          created_at?: string
          id?: string
          nombre?: string
          tipo?: string
          ubicacion?: string
          updated_at?: string
        }
        Relationships: []
      }
      empleados: {
        Row: {
          activa: boolean
          cargo: string
          created_at: string
          id: string
          nombre_completo: string
          updated_at: string
        }
        Insert: {
          activa?: boolean
          cargo: string
          created_at?: string
          id?: string
          nombre_completo: string
          updated_at?: string
        }
        Update: {
          activa?: boolean
          cargo?: string
          created_at?: string
          id?: string
          nombre_completo?: string
          updated_at?: string
        }
        Relationships: []
      }
      pagos_proveedores: {
        Row: {
          concepto: string
          created_at: string
          fecha_hora: string
          id: string
          turno_id: string
          updated_at: string
          valor: number
        }
        Insert: {
          concepto: string
          created_at?: string
          fecha_hora?: string
          id?: string
          turno_id: string
          updated_at?: string
          valor?: number
        }
        Update: {
          concepto?: string
          created_at?: string
          fecha_hora?: string
          id?: string
          turno_id?: string
          updated_at?: string
          valor?: number
        }
        Relationships: [
          {
            foreignKeyName: "pagos_proveedores_turno_id_fkey"
            columns: ["turno_id"]
            isOneToOne: false
            referencedRelation: "turnos"
            referencedColumns: ["id"]
          },
        ]
      }
      parametros: {
        Row: {
          clave: string
          created_at: string
          descripcion: string | null
          id: string
          updated_at: string
          valor: string
        }
        Insert: {
          clave: string
          created_at?: string
          descripcion?: string | null
          id?: string
          updated_at?: string
          valor: string
        }
        Update: {
          clave?: string
          created_at?: string
          descripcion?: string | null
          id?: string
          updated_at?: string
          valor?: string
        }
        Relationships: []
      }
      recepciones: {
        Row: {
          created_at: string
          fecha_hora: string
          id: string
          monto_recibido: number
          observaciones: string | null
          traslado_id: string
          turno_receptor_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          fecha_hora?: string
          id?: string
          monto_recibido?: number
          observaciones?: string | null
          traslado_id: string
          turno_receptor_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          fecha_hora?: string
          id?: string
          monto_recibido?: number
          observaciones?: string | null
          traslado_id?: string
          turno_receptor_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "recepciones_traslado_id_fkey"
            columns: ["traslado_id"]
            isOneToOne: false
            referencedRelation: "traslados"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recepciones_turno_receptor_id_fkey"
            columns: ["turno_receptor_id"]
            isOneToOne: false
            referencedRelation: "turnos"
            referencedColumns: ["id"]
          },
        ]
      }
      traslados: {
        Row: {
          caja_destino_id: string
          caja_origen_id: string
          created_at: string
          estado: string
          fecha_hora: string
          id: string
          monto: number
          observaciones: string | null
          turno_id: string
          updated_at: string
        }
        Insert: {
          caja_destino_id: string
          caja_origen_id: string
          created_at?: string
          estado?: string
          fecha_hora?: string
          id?: string
          monto?: number
          observaciones?: string | null
          turno_id: string
          updated_at?: string
        }
        Update: {
          caja_destino_id?: string
          caja_origen_id?: string
          created_at?: string
          estado?: string
          fecha_hora?: string
          id?: string
          monto?: number
          observaciones?: string | null
          turno_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "traslados_caja_destino_id_fkey"
            columns: ["caja_destino_id"]
            isOneToOne: false
            referencedRelation: "cajas"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "traslados_caja_origen_id_fkey"
            columns: ["caja_origen_id"]
            isOneToOne: false
            referencedRelation: "cajas"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "traslados_turno_id_fkey"
            columns: ["turno_id"]
            isOneToOne: false
            referencedRelation: "turnos"
            referencedColumns: ["id"]
          },
        ]
      }
      turnos: {
        Row: {
          caja_id: string
          created_at: string
          empleado_id: string
          estado: string
          fecha: string
          hora_fin: string | null
          hora_inicio: string
          id: string
          updated_at: string
        }
        Insert: {
          caja_id: string
          created_at?: string
          empleado_id: string
          estado?: string
          fecha: string
          hora_fin?: string | null
          hora_inicio: string
          id?: string
          updated_at?: string
        }
        Update: {
          caja_id?: string
          created_at?: string
          empleado_id?: string
          estado?: string
          fecha?: string
          hora_fin?: string | null
          hora_inicio?: string
          id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "turnos_caja_id_fkey"
            columns: ["caja_id"]
            isOneToOne: false
            referencedRelation: "cajas"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "turnos_empleado_id_fkey"
            columns: ["empleado_id"]
            isOneToOne: false
            referencedRelation: "empleados"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
