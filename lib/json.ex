defmodule Json do

  @niveles_por_defecto %{"A" => 5, "B" => 10, "C" => 15, "Cuauh" => 20}

  def inicio() do 
    json = 
      leer()

    niveles = 
      capturar_niveles(json, @niveles_por_defecto)
    IO.puts("#{inspect niveles}")

    total_goles_individual = 
      suma_goles_individuales_por_equipo(json, %{})
    IO.puts("#{inspect total_goles_individual} ")

    meta_de_goles_grupal = 
      suma_meta_de_goles_grupal_por_equipo(json, niveles, %{}) 
   

    porcentaje_grupal = 
      calcular_porcentaje_grupal_por_equipo(total_goles_individual, meta_de_goles_grupal, %{}) 
    

    mapa_porcentaje_bono = 
      calcular_porcentaje_bono_individual(json, porcentaje_grupal, niveles, %{})
    
    
    json_modificado =
      modificar_json(json, mapa_porcentaje_bono, []) 

    ver(json_modificado)   
  end  
  
  defp leer() do     
       "#{Application.app_dir(:json)}/priv/" 
       |> Path.join("json.json") 
       |> File.read!() 
       |> Poison.decode!()        
  end

  defp capturar_niveles([], mapa_niveles), do: mapa_niveles

  defp capturar_niveles([cabeza | cola], mapa_niveles) do

    if Map.has_key?(mapa_niveles, cabeza["nivel"]) do
      
      capturar_niveles(cola, mapa_niveles)

    else

      valor_nuevo_nivel =
        "ingrese un valor para el nivel #{cabeza["nivel"]}:"
        |> IO.gets()
        |> Integer.parse()
        |> elem(0)

      mapa_niveles = 
        Map.put(mapa_niveles, cabeza["nivel"], valor_nuevo_nivel)
      
      capturar_niveles(cola, mapa_niveles)
    
    end      
  end


  defp suma_goles_individuales_por_equipo(json, suma_goles_por_equipo) do

    suma_goles_por_equipo =
      json
      |> Enum.group_by(fn jugador -> jugador["equipo"]
      end)
      |> Enum.map(fn {equipo, jugadores} -> 
      goles_equipo =
        Enum.reduce(jugadores, 0, fn %{"goles" => goles} , acc -> 
          acc + goles
      end)          
      %{equipo => goles_equipo}
  end)
  end  

  defp suma_meta_de_goles_grupal_por_equipo(json, niveles, meta) do          

  end

  defp calcular_porcentaje_grupal_por_equipo(total_goles_individual, meta_de_goles_grupal,porcentaje_grupal) do
    
    porcentaje_grupal = Map.merge(total_goles_individual, meta_de_goles_grupal, fn _kn, v1, v2 ->  v1 / v2 end)
  
  end

  defp calcular_porcentaje_bono_individual([], porcentaje_grupal, niveles, porcentajes), do: porcentajes

  defp calcular_porcentaje_bono_individual([cabeza | cola], porcentaje_grupal, niveles, porcentajes) do    
    porcentaje_individual =
    (cabeza["goles"]/niveles[cabeza["nivel"]])
    porcentajes = 
     Map.put(porcentajes, cabeza["nombre"], (porcentaje_individual+porcentaje_grupal[cabeza["equipo"]])/2)
    calcular_porcentaje_bono_individual(cola, porcentaje_grupal, niveles, porcentajes)
  end

  defp modificar_json([], _, nuevo_json), do: nuevo_json

  defp modificar_json([cabeza | cola], mapa_porcentaje_bono, nuevo_json) do
    bono =
    cabeza["bono"]*mapa_porcentaje_bono[cabeza["nombre"]] 
    nuevo_json =
    nuevo_json ++ [Map.replace!(cabeza, "sueldo_completo", bono + cabeza["sueldo"])]
    modificar_json(cola, mapa_porcentaje_bono, nuevo_json)
  end
  
  defp ver([]), do: "listo"

  defp ver([cabeza | cola]) do
    IO.puts("#{inspect cabeza}")
    ver(cola)
  end

end
