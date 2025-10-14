Localization = {}

function Localization.init(initial_language)
  Localization.languages = {}
  Localization.texts = {}
  local filenames = love.filesystem.getDirectoryItems("data/text")
  for _, filename in ipairs(filenames) do
    local language = filename:sub(1, -5) -- exclude .txt extension
    Localization.languages[language] = language
    Localization.texts[language] = {}
    local contents = love.filesystem.read("data/text/" .. filename)
    for line in contents:gmatch("[^\n]+") do
      local _, _, key, text = line:find("([^\t]+)\t+([^\t]+)")
      Localization.texts[language][key] = text
    end
  end
  Localization.set_language(initial_language)
end

function Localization.set_language(language)
  if Localization.languages[language] then
    Localization.language = language
  else
    error("Localization: invalid language '" .. language .. "'")
  end
end

function Localization.text(key, args)
  local text = Localization.texts[Localization.language][key]

  if args then
    for i, arg in ipairs(args) do
      local index = text:find("^%$")
      if index then
        text = arg .. text:sub(2, -1)
      else
        index = text:find("[^\\]%$")
        if index then
          text = text:sub(1, index) .. arg .. text:sub(index + 2, -1)
        else
          break
        end
      end
    end
  end

  text, _ = text:gsub("\\%$", "$")
  text, _ = text:gsub("([^\\])\\([^\\])", "%1\n%2")
  text, _ = text:gsub("\\\\", "\\")
  return text
end
