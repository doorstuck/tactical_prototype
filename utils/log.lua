require "/utils/dump_table"

os.remove("debug.txt")

function LogError(message)
  file = io.open("error.txt", "a")
  io.output(file)
  io.write(message .. "\n\r")
  io.close(file)
  LogInfo(message)
end

function LogInfo(message)
  file = io.open("info.txt", "a")
  io.output(file)
  io.write(message .. "\n\r")
  io.close(file)
  LogDebug(message)
end

function LogDebug(message)
  file = io.open("debug.txt", "a")
  io.output(file)
  if type(message) == "table" then
    print_table(message)
  else
    io.write(message .. "\n\r")
  end
  io.close(file)
end
