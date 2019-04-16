defmodule Json do
  @moduledoc """
  toma un json con los datos de jugadores de varios equipos y calcula el salario de cada uno
  """

  @niveles_por_defecto %{"A" => 5, "B" => 10, "C" => 15, "Cuauh" => 20}

  @doc """
  establece el orden de ejecución de totas las demás funciones  
  """
  def inicio() do
    json = leer()

    niveles = capturar_niveles(json, @niveles_por_defecto)

    total_goles_individual = suma_goles_individuales_por_equipo(json)

    meta_de_goles_grupal = suma_meta_de_goles_grupal_por_equipo(json, niveles)

    porcentaje_grupal =
      calcular_porcentaje_grupal_por_equipo(total_goles_individual, meta_de_goles_grupal)

    mapa_porcentaje_bono = calcular_porcentaje_bono_individual(json, porcentaje_grupal, niveles)

    json_modificado = modificar_json(json, mapa_porcentaje_bono)

    ver(json_modificado)
  end

  @doc """
  busca el json que debe guardarse en la carpeta priv,
  este debe ser una lista de mapas con el nombre de json  
  """
  def leer() do
    "#{Application.app_dir(:json)}/priv/"
    |> Path.join("prueba.json")
    |> File.read!()
    |> Poison.decode!()
  end

  @doc """
  recibe una lista de mapas con niveles predeterminados, 
  pero si encuentra un nivel nuevo en el json pedirá un valor para este
  y lo agregara a la lista 
  """
  def capturar_niveles([], mapa_niveles), do: mapa_niveles

  def capturar_niveles([cabeza | cola], mapa_niveles) do
    if Map.has_key?(mapa_niveles, cabeza["nivel"]) do
      capturar_niveles(cola, mapa_niveles)
    else
      valor_nuevo_nivel =
        "ingrese un valor para el nivel #{cabeza["nivel"]}:"
        |> IO.gets()
        |> Integer.parse()
        |> elem(0)

      mapa_niveles = Map.put(mapa_niveles, cabeza["nivel"], valor_nuevo_nivel)

      capturar_niveles(cola, mapa_niveles)
    end
  end

  @doc """
  crea un mapa con los equipos y la suma de los goles metidos por cada uno
  """
  def suma_goles_individuales_por_equipo(json) do
    json
    |> Enum.group_by(fn jugador -> jugador["equipo"] end)
    |> Enum.map(fn {equipo, jugadores} ->
      goles_equipo =
        Enum.reduce(jugadores, 0, fn %{"goles" => goles}, acc ->
          acc + goles
        end)

      %{equipo => goles_equipo}
    end)
    |> Enum.reduce(%{}, fn mapa, acc -> Map.merge(acc, mapa) end)
  end

  @doc """
  crear un mapa con los equipos y la suma de los goles que debería meter cada uno
  """
  def suma_meta_de_goles_grupal_por_equipo(json, niveles) do
    json
    |> Enum.group_by(fn jugador -> jugador["equipo"] end)
    |> Enum.map(fn {equipo, jugadores} ->
      meta_de_goles_por_equipo =
        Enum.reduce(jugadores, 0, fn %{"nivel" => nivel}, acc ->
          acc + niveles[nivel]
        end)

      %{equipo => meta_de_goles_por_equipo}
    end)
    |> Enum.reduce(%{}, fn mapa, acc -> Map.merge(acc, mapa) end)
  end

  @doc """
  divide la suma de los goles que metieron cada equipo
  y los que debían de meter para sacar un mapa con el porcentaje grupal por equipo
  """
  def calcular_porcentaje_grupal_por_equipo(total_goles_por_equipo, meta_de_goles_por_equipo) do
    Map.merge(total_goles_por_equipo, meta_de_goles_por_equipo, fn _kn, v1, v2 ->
      v1
      |> Kernel./(v2)
      |> Float.round(2)
    end)
  end

  @doc """
  toma el porcentaje de goles individual y el grupal teniendo en cuenta el equipo,
  para sacar una mapa de el porcentaje de bono de cada jugador  
  """
  def calcular_porcentaje_bono_individual(json, porcentaje_grupal, niveles) do
    Enum.reduce(json, %{}, fn %{
                                "goles" => goles,
                                "nivel" => nivel,
                                "equipo" => equipo,
                                "nombre" => nombre
                              },
                              acc ->
      individual =
        goles
        |> Kernel./(niveles[nivel])
        |> Kernel.+(porcentaje_grupal[equipo])
        |> Kernel./(2)
        |> Float.round(2)

      Map.merge(acc, %{nombre => individual})
    end)
  end

  @doc """
    Toma el json y remplaza el valor de sueldo_completo, 
    sumando el bono correspondiente al porcentaje_de_bono y sumando el sueldo base
  """
  def modificar_json(json, mapa_porcentaje_bono) do
    Enum.map(json, fn jugadores ->
      Map.replace!(
        jugadores,
        "sueldo_completo",
        jugadores["bono"] * mapa_porcentaje_bono[jugadores["nombre"]] + jugadores["sueldo"]
      )
    end)
  end

  @doc """
  muestra el json modificado haciendo un salto de linea por jugador
  """
  def ver(json) do
    Enum.map(json, fn jugador -> IO.puts("#{inspect(jugador)}") end)
  end
end
