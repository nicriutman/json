defmodule Json do
  @niveles_por_defecto %{"A" => 5, "B" => 10, "C" => 15, "Cuauh" => 20}

  def inicio() do
    json = leer()

    niveles = capturar_niveles(json, @niveles_por_defecto)
    IO.puts("#{inspect(niveles)}")

    total_goles_individual = suma_goles_individuales_por_equipo(json)
    IO.puts("#{inspect(total_goles_individual)}")

    meta_de_goles_grupal = suma_meta_de_goles_grupal_por_equipo(json, niveles)
    IO.puts("#{inspect(meta_de_goles_grupal)}")

    porcentaje_grupal =
      calcular_porcentaje_grupal_por_equipo(total_goles_individual, meta_de_goles_grupal)

    IO.puts("#{inspect(porcentaje_grupal)}")

    mapa_porcentaje_bono = calcular_porcentaje_bono_individual(json, porcentaje_grupal, niveles)
    IO.puts("#{inspect(mapa_porcentaje_bono)}")

    json_modificado = modificar_json(json, mapa_porcentaje_bono)

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

      mapa_niveles = Map.put(mapa_niveles, cabeza["nivel"], valor_nuevo_nivel)
      capturar_niveles(cola, mapa_niveles)
    end
  end

  defp suma_goles_individuales_por_equipo(json) do
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

  defp suma_meta_de_goles_grupal_por_equipo(json, niveles) do
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

  defp calcular_porcentaje_grupal_por_equipo(total_goles_por_equipo, meta_de_goles_por_equipo) do
    Map.merge(total_goles_por_equipo, meta_de_goles_por_equipo, fn _kn, v1, v2 -> v1 / v2 end)
  end

  defp calcular_porcentaje_bono_individual(json, porcentaje_grupal, niveles) do
    Enum.reduce(json, %{}, fn jugador, acc ->
      Map.merge(acc, %{
        jugador["nombre"] =>
          (jugador["goles"] / niveles[jugador["nivel"]] + porcentaje_grupal[jugador["equipo"]]) /
            2
      })
    end)
  end

  defp modificar_json(json, mapa_porcentaje_bono) do
    Enum.map(json, fn jugadores ->
      Map.replace!(
        jugadores,
        "sueldo_completo",
        jugadores["bono"] * mapa_porcentaje_bono[jugadores["nombre"]] + jugadores["sueldo"]
      )
    end)
  end

  defp ver(json) do
    Enum.map(json, fn jugador -> IO.puts("#{inspect(jugador)}") end)
  end
end
