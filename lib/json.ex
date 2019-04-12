defmodule Json do

  def main() do 
    json = leer()
    mapa_niveles = %{}
    niveles = 
    json
    |> capturar_niveles(mapa_niveles)     
    total_goles = 
    json
    |> suma_goles_individuales(0)     
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
    suma_goles = suma_goles + h["goles"]
    suma_goles_individuales(t, suma_goles)
  end
  
  defp leer() do     
       "#{Application.app_dir(:json)}/priv/" 
       |> Path.join("json.json") 
       |> File.read!() 
       |> Poison.decode!()        
  end

end
