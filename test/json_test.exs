defmodule JsonTest do
  use ExUnit.Case
  import Mock
  alias Json
  require Logger

  
  test "deveria agregar nuevos niveles" do
    with_mocks( 
      [ 
        { 
          IO, 
          [], 
          [ 
            gets: fn _ -> "25\n" end 
          ] 
        } 
      ] 
    ) do         
    niveles_por_default =
      %{"A" => 5, "B" => 10, "C" => 15, "Cuauh" => 20}
    json_de_prueba = 
      [%{"nivel" => "prueba1"},%{"nivel" => "prueba2"},%{"nivel" => "prueba3"}]
      Logger.error("#{inspect Json.__info__(:functions)}")
      resultado =
      Json.capturar_niveles(json_de_prueba, niveles_por_default)
      esperado =
      %{"A" => 5, "B" => 10, "C" => 15, "Cuauh" => 20, "prueba1" => 25, "prueba2" => 25, "prueba3" => 25}
      assert esperado == resultado
      end
  end
  
end
