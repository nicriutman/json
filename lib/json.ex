defmodule Json do

  def main() do 
    json = 
    leer()    
    niveles = 
    capturar_niveles(json, %{})     
    total_goles_individual = 
    suma_goles_individuales(json, 0)   
    meta_de_goles_grupal = 
    suma_meta_de_goles_grupal(json, niveles, 0)  
    porcentaje_grupal = 
    calcular_porcentaje_grupal(total_goles_individual, meta_de_goles_grupal)    
    mapa_porcentaje_bono = 
    calcular_porcentaje_bono_individual(json, porcentaje_grupal, niveles, %{})     
  end  

  defp capturar_niveles([], mapa_niveles), do: mapa_niveles

  defp capturar_niveles([h | t], mapa_niveles) do  
    if Map.has_key?(mapa_niveles, h["nivel"]) do
      capturar_niveles(t, mapa_niveles)
    else
      mapa_niveles = 
      Map.put(mapa_niveles, h["nivel"],
      IO.gets("ingrese un valor para el nivel #{inspect h["nivel"]}:")
      |> Integer.parse()
      |> elem(0))
      capturar_niveles(t, mapa_niveles)
    end      
  end

  defp suma_goles_individuales([], suma_goles), do: suma_goles

  defp suma_goles_individuales([h | t], suma_goles) do
    suma_goles = 
    suma_goles + h["goles"]
    suma_goles_individuales(t, suma_goles)
  end
  
  defp suma_meta_de_goles_grupal([], niveles, meta), do: meta

  defp suma_meta_de_goles_grupal([h | t], niveles, meta) do
    meta = 
    niveles[h["nivel"]] + meta    
    suma_meta_de_goles_grupal(t, niveles, meta)
  end

  defp calcular_porcentaje_bono_individual([], porcentaje_grupal, niveles, porcentajes), do: porcentajes

  defp calcular_porcentaje_bono_individual([h | t], porcentaje_grupal, niveles, porcentajes) do    
    porcentaje_individual =
    (h["goles"]/niveles[h["nivel"]])
    porcentajes = 
    Map.put(porcentajes, h["nombre"], (porcentaje_individual+porcentaje_grupal)/2)
    calcular_porcentaje_bono_individual(t, porcentaje_grupal, niveles, porcentajes)
  end

  defp calcular_porcentaje_grupal(total_goles_individual, meta_de_goles_grupal) do
    porcentaje_grupal = 
    total_goles_individual/meta_de_goles_grupal
  end    

  defp leer() do     
       "#{Application.app_dir(:json)}/priv/" 
       |> Path.join("json.json") 
       |> File.read!() 
       |> Poison.decode!()        
  end

end
