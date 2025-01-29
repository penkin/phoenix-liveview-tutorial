# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias Werdle.{Repo, WordBank}
alias Werdle.WordBank.Word

"priv/repo/solves-data.csv"
|> File.stream!()
|> NimbleCSV.RFC4180.parse_stream()
|> Enum.each(fn [solve] ->
  WordBank.create_solve(%{"name" => solve})
end)

date_time = DateTime.utc_now() |> DateTime.truncate(:second)

WordList.getStream!()
|> Enum.filter(fn word -> String.length(word) == 5 end)
|> Enum.map(fn word -> %{ name: word, inserted_at: date_time, updated_at: date_time } end)
|> Enum.chunk_every(1000)
|> Enum.each(fn word_batch -> Repo.insert_all(Word, word_batch) end)
