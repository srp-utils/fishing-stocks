local hook = require 'samp.events';
local encoding = require 'encoding';
local u8 = encoding.UTF8;

encoding.default = 'cp1251';

local currentSkill = -1;

local PRICE_MAP = {
  ['Малоротый окунь'] = {100, 300},
  ['Радужная форель'] = {200, 400},
  ['Лосось']          = {250, 450},
  ['Карп']            = {80, 240},
  ['Сом']             = {500, 800},
  ['Тунец']           = {480, 950},
  ['Лещ']             = {130, 330},
  ['Желтый судак']    = {200, 400},
  ['Барабулька']      = {4800, 6800},
  ['Угорь']           = {480, 950},
  ['Осьминог']        = {600, 1000},
  ['Кальмар']         = {500, 1000},
  ['Морской огурец']  = {175, 375},
  ['Мелкая камбала']  = {225, 425},
  ['Рыба-еж']         = {525, 1024},
  ['Сардина']         = {120, 320},
  ['Анчоус']          = {120, 320},
  ['Щука']            = {320, 520},
  ['Сельдь']          = {95, 295},
  ['Тигровая форель'] = {320, 520},
  ['Голавль']         = {130, 330} 
};

function main()
  while true do
    if isSampAvailable() and sampIsLocalPlayerSpawned() and not isInitialized() then
      wait(5000);
      sampSendChat('/fish skill');
    end

    wait(5000);
  end

  wait(-1);
end

function hook.onShowDialog(id, style, title, button, button2, text)
  if isSRP() then
    local status = isInitialized();

    if status and title:find('Рыболовный магазин') and title:find('Рыболовные товары') then
      local resultText = {};

      for i, line in ipairs(splitDialogBody(text)) do
        if i == 1 then
          line = line:gsub('Цена за кг', 'Цена за кг\t{FFFFFF}Выгода');
        end

        local regexp = '([А-Яа-я -]+).*$(%d+%.?%d*)';

        if line:find(regexp) then
          local name, currentPrice = line:match(regexp);
          local u8name = u8:encode(name);

          if u8name and PRICE_MAP[u8name] then
            local shopBuff = getSkillShopBuff();
            local minPrice = PRICE_MAP[u8name][1] * shopBuff;
            local maxPrice = PRICE_MAP[u8name][2] * shopBuff;
            local percent = math.floor(((currentPrice - minPrice) / (maxPrice - minPrice)) * 100);

            line = line:gsub(
              '$' .. currentPrice, 
              string.format('$%d\t%s', currentPrice, formatPercent(percent))
            );
          end
        end

        table.insert(resultText, line);
      end

      return {id, style, title, button, button2, table.concat(resultText, '\n')};
    end

    if not status and title:find('Навык') and title:find('Рыбалка') and button:equals('Бонусы') then
      currentSkill = tonumber(text:match('Текущий уровень: {FFFFFF}(%d+)'));

      return false;
    end
  end
end

function hook.onServerMessage(color, text)
  if isSRP() then
    if color == 1790050303 and text:find('Навык рыбной ловли повышен до') then
      currentSkill = tonumber(msg:match('.*Навык рыбной ловли повышен до {.*}(%d+)'));
    end
  end
end

function getSkillShopBuff()
  if currentSkill >= 10 then
    return 1.30;
  end

  if currentSkill >= 9 then
    return 1.26;
  end

  if currentSkill >= 8 then
    return 1.22;
  end

  if currentSkill >= 7 then
    return 1.18;
  end

  if currentSkill >= 5 then
    return 1.15;
  end

  if currentSkill >= 3 then
    return 1.07;
  end

  if currentSkill >= 1 then
    return 1.03;
  end

  return 1;
end

function formatPercent(value)
  local color = 'EF5D52';

  if value >= 70 then
    color = 'EFED62';
  end

  if value >= 90 then
    color = '51F079';
  end

  return string.format('{%s}%s', color, value) .. '%%';
end

function isSRP()
  local serverName = sampGetCurrentServerName();

  return serverName:find('Samp%-Rp.Ru') ~= nil or serverName:find('SRP') ~= nil;
end

function splitDialogBody(body)
  local result = {};

  for i in body:gmatch('[^\r\n]+') do
    if i ~= nil then
      table.insert(result, i);
    end
  end

  return result;
end

function isInitialized()
  return currentSkill >= 0;
end


local find = string.find;
local match = string.match;
local gsub = string.gsub;

function string.find(self, pattern)
  return find(self, u8:decode(pattern), init, plain);
end

function string.gsub(self, pattern, pattern2)
  return gsub(self, u8:decode(pattern), u8:decode(pattern2));
end

function string.match(self, pattern)
  return match(self, u8:decode(pattern));
end

function string.equals(self, s2)
  return self == u8:decode(s2);
end
