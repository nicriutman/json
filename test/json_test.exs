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
      resultado =
      Json.capturar_niveles(json_de_prueba, niveles_por_default)
      esperado =
      %{"A" => 5, "B" => 10, "C" => 15, "Cuauh" => 20, "prueba1" => 25, "prueba2" => 25, "prueba3" => 25}
      assert esperado == resultado
      end
  end
  
  test "debe sumar los goles individuales de cada equipo" do       
    json_de_prueba =
    "#{Application.app_dir(:json)}/priv/" 
    |> Path.join("json.json") 
    |> File.read!() 
    |> Poison.decode!()
      resultado =
      Json.suma_goles_individuales_por_equipo(json_de_prueba)
      esperado =
      %{"azul" => 37, "rojo" => 19}
      assert esperado == resultado
  end

  test "debe sumar la meta de goles que deben meter" do       
    json_de_prueba =
      "#{Application.app_dir(:json)}/priv/" 
      |> Path.join("json.json") 
      |> File.read!() 
      |> Poison.decode!() 
    niveles_por_default =
     %{"A" => 5, "B" => 10, "C" => 15, "Cuauh" => 20}
    resultado =
      Json.suma_meta_de_goles_grupal_por_equipo(json_de_prueba, niveles_por_default)
    esperado =
      %{"azul" => 25, "rojo" => 25}
    assert esperado == resultado
  end

  test "calcula el porcentaje de goles metidos por equipo" do       
    total_goles_por_equipo = 
      %{"azul" => 37, "rojo" => 19}
    meta_de_goles_por_equipo =
      %{"azul" => 25, "rojo" => 25}
    resultado =
      Json.calcular_porcentaje_grupal_por_equipo(total_goles_por_equipo, meta_de_goles_por_equipo)
    esperado =
      %{"azul" => 1.48, "rojo" => 0.76}
    assert esperado == resultado
  end

  test "calcula el bono de cada jugador" do
    json =
      "#{Application.app_dir(:json)}/priv/" 
      |> Path.join("json.json") 
      |> File.read!() 
      |> Poison.decode!()       
    porcentaje_grupal = 
      %{"azul" => 1.48, "rojo" => 0.76}
    niveles = 
      %{"A" => 5, "B" => 10, "C" => 15, "Cuauh" => 20}
    resultado =
      Json.calcular_porcentaje_bono_individual(json, porcentaje_grupal, niveles)
    esperado =
    %{"Cosme Fulanito" => 1.44, "EL Cuauh" => 1.49, "El Rulo" => 0.83, "Juan Perez" => 0.71}
    assert esperado == resultado
  end
  
  test "modifica el valor de la clave sueldo_completo" do
    json =
      "#{Application.app_dir(:json)}/priv/" 
      |> Path.join("json.json") 
      |> File.read!() 
      |> Poison.decode!()       
    porcentaje_de_bono =
      %{"Cosme Fulanito" => 1.44, "EL Cuauh" => 1.49, "El Rulo" => 0.8300000000000001, "Juan Perez" => 0.7133333333333334}
    resultado =
      Json.modificar_json(json, porcentaje_de_bono)
    esperado =
    [%{"bono" => 25000, "equipo" => "rojo", "goles" => 10, "nivel" => "C", "nombre" => "Juan Perez", "sueldo" => 50000, "sueldo_completo" => 67833.33333333334}, 
    %{"bono" => 30000, "equipo" => "azul", "goles" => 30, "nivel" => "Cuauh", "nombre" => "EL Cuauh", "sueldo" => 100000, "sueldo_completo" => 1.447e5}, 
    %{"bono" => 10000, "equipo" => "azul", "goles" => 7, "nivel" => "A", "nombre" => "Cosme Fulanito", "sueldo" => 20000, "sueldo_completo" => 3.44e4}, 
    %{"bono" => 15000, "equipo" => "rojo", "goles" => 9, "nivel" => "B", "nombre" => "El Rulo", "sueldo" => 30000, "sueldo_completo" => 42450.0}]
    assert esperado == resultado
  end    

end
