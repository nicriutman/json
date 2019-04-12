defmodule Json do

  def main() do    
    json = leer() 
    total_goles = 
    json
    |> suma_goles_individuales(0)    
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
