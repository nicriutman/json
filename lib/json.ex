defmodule Json do

  @niveles_por_defecto %{"A" => 5, "B" => 10, "C" => 15, "Cuauh" => 20}

  def inicio() do 
    json = 
      leer()

    niveles = 
      capturar_niveles(json, @niveles_por_defecto)

    total_goles_individual = 
      suma_goles_individuales(json, 0)

    meta_de_goles_grupal = 
      suma_meta_de_goles_grupal(json, niveles, 0) 

    porcentaje_grupal = 
      calcular_porcentaje_grupal(total_goles_individual, meta_de_goles_grupal) 

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

  defp suma_goles_individuales_por_equipo([], suma_goles_por_equipo), do: suma_goles_por_equipo

  defp suma_goles_individuales_por_equipo([cabeza | cola], suma_goles_por_equipo) do
    if Map.has_key?(suma_goles_por_equipo, cabeza["equipo"]) do
      replace!(suma_goles_por_equipo, cabeza["equipo"], suma_goles_por_equipo[cabeza["equipo"]] + cabeza["goles"])
      suma_goles_individuales_por_equipo(cola, suma_goles_por_equipo)
    else
      Map.put(suma_goles_por_equipo, cabeza["equipo"],cabeza["goles"])      
      suma_goles_individuales_por_equipo(cola, suma_goles_por_equipo)
    end

  end
  
  defp suma_meta_de_goles_grupal([], niveles, meta), do: meta

  defp suma_meta_de_goles_grupal([cabeza | cola], niveles, meta) do
    meta = 
    niveles[cabeza["nivel"]] + meta    
    suma_meta_de_goles_grupal(cola, niveles, meta)
  end

  defp calcular_porcentaje_bono_individual([], porcentaje_grupal, niveles, porcentajes), do: porcentajes

  defp calcular_porcentaje_bono_individual([cabeza | cola], porcentaje_grupal, niveles, porcentajes) do    
    porcentaje_individual =
    (cabeza["goles"]/niveles[cabeza["nivel"]])
    porcentajes = 
    Map.put(porcentajes, cabeza["nombre"], (porcentaje_individual+porcentaje_grupal)/2)
    calcular_porcentaje_bono_individual(cola, porcentaje_grupal, niveles, porcentajes)
  end

  defp calcular_porcentaje_grupal(total_goles_individual, meta_de_goles_grupal) do
    porcentaje_grupal = 
    total_goles_individual/meta_de_goles_grupal
  end    

  defp modificar_json([], _, nuevo_json), do: nuevo_json

  defp modificar_json([cabeza | cola], mapa_porcentaje_bono, nuevo_json) do
    bono =
    h["bono"]*mapa_porcentaje_bono[cabeza["nombre"]] 
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
