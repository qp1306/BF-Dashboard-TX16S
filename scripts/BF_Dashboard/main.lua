-- Betaflight / ELRS CRSF Dashboard for RadioMaster TX16S MK3
-- v1.3 - voltage-based battery ring, auto cell-count detection, ELRS/CRSF telemetry mapping.

local NAME = "BF Dashboard"
local VERSION = "v1.3"

local BASE_W, BASE_H = 480, 272
local UI_SCALE = 1
local function X(v) return math.floor(v * UI_SCALE + 0.5) end
local function Y(v) return math.floor(v * UI_SCALE + 0.5) end
local function S(v) return math.floor(v * UI_SCALE + 0.5) end

local bg = nil
local bg_loaded = false
local default_pic_obj = nil
local model_pic_obj = nil
local cached_model_name = ""
local cached_pic_path = ""
local icons = {}

local last_rtc = 0
local armed_seconds = 0
local was_armed = false
local max_current = 0
local max_power = 0
local max_speed = 0

local CYAN_COL = lcd.RGB(0, 200, 255)
local TINY = TINSIZE or 0

local options = {
  { "SquareColor", COLOR, WHITE },
  { "BackgroundColor", COLOR, BLACK },
  { "UsePngBg", BOOL, 1 },
  { "ValueColor", COLOR, GREEN },
  { "ShowImage", BOOL, 1 },
  { "CellCount", VALUE, 0, 0, 12 }, -- retained for future settings; v1.3 auto-detects cells
}

local sensor_cache = {}

local function first_field(names)
  for i = 1, #names do
    local info = getFieldInfo(names[i])
    if info then return info.id end
  end
  return nil
end

local function sensor(name_list, default)
  local key = table.concat(name_list, "/")
  if sensor_cache[key] == nil then
    sensor_cache[key] = first_field(name_list) or false
  end
  local id = sensor_cache[key]
  if id then
    local v = getValue(id)
    if v ~= nil then return v end
  end
  return default or 0
end

local function num(v, default)
  if type(v) == "number" then return v end
  if type(v) == "string" then
    -- EdgeTX sometimes returns telemetry as text with units, e.g. "100mW", "22.3V", "-26dB".
    local n = tonumber(v)
    if n ~= nil then return n end
    local m = string.match(v, "%-?%d+%.?%d*")
    return tonumber(m) or default or 0
  end
  return default or 0
end

local function str(v, default)
  if v == nil then return default or "--" end
  return tostring(v)
end

local function load_background()
  if bg_loaded then return end
  bg_loaded = true
  local p = "/WIDGETS/BF_Dashboard/background.png"
  if fstat(p) then bg = Bitmap.open(p) end
end

local function draw_box(x, y, w, h, color)
  lcd.drawRectangle(X(x), Y(y), S(w), S(h), color)
end

local function draw_hline(x, y, w, color)
  lcd.drawLine(X(x), Y(y), X(x + w), Y(y), SOLID, color)
end

local function draw_vline(x, y, h, color)
  lcd.drawLine(X(x), Y(y), X(x), Y(y + h), SOLID, color)
end

local function draw_battery_ring(xs, ys, percent, mah, value_color)
  percent = math.max(0, math.min(100, math.floor(num(percent, 0) + 0.5)))
  mah = math.max(0, math.floor(num(mah, 0) + 0.5))
  local color = GREEN
  if percent < 20 then color = RED elseif percent < 40 then color = ORANGE end
  local r1, r2 = S(30), S(43)
  lcd.drawAnnulus(xs, ys, r1, r2, 0, 360, DARKGREY)
  if percent > 0 then
    lcd.drawAnnulus(xs, ys, r1, r2, 270, 270 + (percent * 3.6), color)
  end
  lcd.drawText(xs, ys - S(5), string.format("%d%%", percent), CENTER + VCENTER + MIDSIZE + BOLD + value_color)
  lcd.drawText(xs, ys + S(15), string.format("%dmAh", mah), CENTER + VCENTER + SMLSIZE + value_color)
end

local function draw_lq_bars(xs, ys, lq)
  lq = math.max(0, math.min(100, math.floor(num(lq, 0) + 0.5)))
  local bw, gap = S(5), S(7)
  local active = math.floor((lq + 19) / 20)
  for i = 1, 5 do
    local c = DARKGREY
    if i <= active then
      if i <= 1 then c = RED elseif i == 2 then c = ORANGE elseif i == 3 then c = YELLOW else c = GREEN end
    end
    lcd.drawFilledRectangle(xs + (i - 1) * gap, ys + S(10 - i * 2), bw, S(4 + i * 2), c)
  end
end

local function draw_small_battery(x, y, w, h, pct, color)
  pct = math.max(0, math.min(100, math.floor(num(pct, 0) + 0.5)))
  local fill = math.floor((w - 4) * pct / 100 + 0.5)
  lcd.drawRectangle(X(x), Y(y), S(w), S(h), WHITE)
  lcd.drawFilledRectangle(X(x + w), Y(y + 4), S(3), S(h - 8), WHITE)
  if fill > 0 then lcd.drawFilledRectangle(X(x + 2), Y(y + 2), S(fill), S(h - 4), color) end
end

local function tx_percent(v)
  -- 2S Li-ion/LiPo radio pack approximation: 8.4V full, 6.6V low.
  v = num(v, 0)
  if v <= 0 then return 0 end
  local p = (v - 6.6) / (8.4 - 6.6) * 100
  if p < 0 then p = 0 elseif p > 100 then p = 100 end
  return p
end

local function has_gps(sats, gspd, dist, hdg)
  return num(sats, 0) > 0 or num(gspd, 0) > 0 or num(dist, 0) > 0 or num(hdg, 0) > 0
end

local function decode_rate(rfmd)
  -- CRSF/ELRS RFMD values vary a little between firmware builds.
  -- This table is intentionally easy to edit if your radio shows a different rate for the same RFMD number.
  local r = math.floor(num(rfmd, -1) + 0.5)
  local map = {
    [0] = "4Hz",
    [1] = "50Hz",
    [2] = "150",
    [3] = "250",
    [4] = "500",
    [5] = "F500",
    [6] = "F1000",
    [7] = "D50",
    [8] = "D250",
    [9] = "D500",
    [10] = "F500",
    [11] = "F1000"
  }
  return map[r] or tostring(r)
end

local function auto_cell_count(pack_v)
  pack_v = num(pack_v, 0)
  if pack_v <= 0 then return 0 end
  local cells = math.floor((pack_v / 4.35) + 1.0)
  if cells < 1 then cells = 1 end
  if cells > 12 then cells = 12 end
  return cells
end

local function battery_percent_from_cell(cell_v)
  -- Voltage-based LiPo estimate so different pack capacities work without changing Lua.
  -- 4.20V/cell and above = full; 3.30V/cell = empty.
  cell_v = num(cell_v, 0)
  if cell_v >= 4.20 then return 100 end
  if cell_v >= 3.80 then return math.floor(50 + ((cell_v - 3.80) / 0.40) * 50 + 0.5) end
  if cell_v >= 3.50 then return math.floor(15 + ((cell_v - 3.50) / 0.30) * 35 + 0.5) end
  if cell_v >= 3.30 then return math.floor(((cell_v - 3.30) / 0.20) * 15 + 0.5) end
  return 0
end

local function update_model_image(show)
  local current_model_name = model.getInfo().name or ""
  if cached_model_name ~= current_model_name then
    cached_model_name = current_model_name
    local safe = string.gsub(current_model_name, "[<>:\"/\\|?*]", "")
    safe = string.gsub(safe, "^%s*(.-)%s*$", "%1")
    safe = string.gsub(safe, "%s+", "_")
    cached_pic_path = "/WIDGETS/BF_Dashboard/" .. safe .. ".png"
    if show == 1 and safe ~= "" and fstat(cached_pic_path) then
      model_pic_obj = Bitmap.open(cached_pic_path)
    else
      model_pic_obj = nil
    end
  end
end

local function draw_top_item(x, title, value, color)
  lcd.drawText(X(x), Y(8), title, CENTER + VCENTER + WHITE)
  lcd.drawText(X(x), Y(28), value, CENTER + VCENTER + MIDSIZE + color)
end

local function create(zone, opts)
  sensor_cache = {}
  default_pic_obj = Bitmap.open("/WIDGETS/BF_Dashboard/default.png")
  icons.sat = Bitmap.open("/WIDGETS/BF_Dashboard/ico_sat.png")
  icons.alt = Bitmap.open("/WIDGETS/BF_Dashboard/ico_alt.png")
  icons.hdg = Bitmap.open("/WIDGETS/BF_Dashboard/ico_hdg.png")
  icons.home = Bitmap.open("/WIDGETS/BF_Dashboard/ico_home.png")
  icons.batt = Bitmap.open("/WIDGETS/BF_Dashboard/ico_batt.png")
  icons.bolt = Bitmap.open("/WIDGETS/BF_Dashboard/ico_bolt.png")
  icons.stop = Bitmap.open("/WIDGETS/BF_Dashboard/ico_stop.png")
  icons.clock = Bitmap.open("/WIDGETS/BF_Dashboard/ico_clock.png")
  icons.ant = Bitmap.open("/WIDGETS/BF_Dashboard/ico_ant.png")
  icons.link = Bitmap.open("/WIDGETS/BF_Dashboard/ico_link.png")
  return { zone = zone, options = opts }
end

local function update(widget, opts)
  widget.options = opts
  sensor_cache = {}
  bg_loaded = false
end

local function background(widget)
end

local function draw_icon(name, x, y)
  local b = icons[name]
  if b then lcd.drawBitmap(b, X(x), Y(y)) end
end

local function refresh(widget, event, touchState)
  local sw = LCD_W or widget.zone.w
  local sh = LCD_H or widget.zone.h
  UI_SCALE = math.min(sw / BASE_W, sh / BASE_H)

  lcd.setColor(CUSTOM_COLOR, widget.options.BackgroundColor)
  local bg_color = lcd.getColor(CUSTOM_COLOR)
  lcd.setColor(CUSTOM_COLOR, widget.options.SquareColor)
  local line_color = lcd.getColor(CUSTOM_COLOR)
  lcd.setColor(CUSTOM_COLOR, widget.options.ValueColor)
  local value_color = lcd.getColor(CUSTOM_COLOR)

  lcd.drawFilledRectangle(0, 0, sw, sh, bg_color)
  if widget.options.UsePngBg == 1 then
    load_background()
    if bg then lcd.drawBitmap(bg, 0, 0) end
  end

  local fm_raw = sensor({"FM", "FMode", "FlightMode", "Flight Mode"}, "--")
  local fm = str(fm_raw, "--")
  local is_disarmed = (string.find(fm, "!", 1, true) ~= nil) or (string.find(fm, "*", 1, true) ~= nil)
  local is_armed = (fm ~= "--") and not is_disarmed
  local clean_fm = string.gsub(fm, "!", "")
  clean_fm = string.gsub(clean_fm, "%*", "")
  if clean_fm == "" then clean_fm = "--" end

  if is_armed and not was_armed then
    armed_seconds = 0
    max_current = 0
    max_power = 0
    max_speed = 0
  end
  was_armed = is_armed

  local now = getRtcTime()
  if now ~= last_rtc then
    last_rtc = now
    if is_armed then armed_seconds = armed_seconds + 1 end
  end

  local tx_v = num(getValue("tx-voltage") or getValue("TxBt"), 0)
  local lq = num(sensor({"RQly", "RQLY", "RQLy", "LQ"}, 0), 0)
  local snr = num(sensor({"RSNR", "RSnr", "SNR"}, 0), 0)
  local rfmd = sensor({"RFMD", "RFmd", "Rate"}, -1)
  local tpwr = num(sensor({"TPWR", "TPwr", "Pwr"}, 0), 0)
  local rssi1 = num(sensor({"1RSS", "1RSSI", "RSSI"}, 0), 0)
  local rssi2 = num(sensor({"2RSS", "2RSSI"}, 0), 0)
  local trss = num(sensor({"TRSS", "TRSSI"}, 0), 0)
  local tqly = num(sensor({"TQly", "TQLY"}, 0), 0)

  local pack_v = num(sensor({"RxBt", "VFAS", "Volt"}, 0), 0)
  local curr = num(sensor({"Curr", "AMP", "Current"}, 0), 0)
  if math.abs(curr) > 2000 then curr = curr / 100 elseif math.abs(curr) > 200 then curr = curr / 10 end
  local capa = num(sensor({"Capa", "mAh"}, 0), 0)
  local bf_batp = num(sensor({"Bat%", "B%", "Fuel"}, 0), 0)

  local gspd = num(sensor({"GSpd", "Gspd", "GPS Speed"}, 0), 0)
  local alt = num(sensor({"Alt", "GAlt"}, 0), 0)
  local sats = num(sensor({"Sats", "GPS Sats"}, 0), 0)
  local hdg = num(sensor({"Hdg", "Head"}, 0), 0)
  local dist = num(sensor({"Dist", "GDist", "Home", "HomeDist", "DistHome", "GPS Dist"}, 0), 0)
  local gps_ok = has_gps(sats, gspd, dist, hdg)

  local cell_count = auto_cell_count(pack_v)
  local cell_v = 0
  if cell_count > 0 then cell_v = pack_v / cell_count end
  local batp = battery_percent_from_cell(cell_v)
  if pack_v <= 0 then batp = bf_batp end
  local watts = pack_v * curr

  if is_armed then
    if curr > max_current then max_current = curr end
    if watts > max_power then max_power = watts end
    if gspd > max_speed then max_speed = gspd end
  end

  draw_top_item(35, "FM", clean_fm, value_color)
  lcd.drawText(X(35), Y(48), is_armed and "ARMED" or "DISARMED", CENTER + VCENTER + SMLSIZE + (is_armed and GREEN or RED))
  draw_vline(78, 9, 42, line_color)
  draw_top_item(115, "LQ", string.format("%d%%", lq), value_color)
  draw_lq_bars(X(99), Y(42), lq)
  draw_vline(152, 9, 42, line_color)
  draw_top_item(190, "SNR", string.format("%ddB", snr), value_color)
  draw_vline(230, 9, 42, line_color)
  draw_top_item(270, "RATE", decode_rate(rfmd), value_color)
  draw_vline(312, 9, 42, line_color)
  local tpwr_text = (tpwr >= 1000) and string.format("%.1fW", tpwr / 1000) or string.format("%dmW", math.floor(tpwr + 0.5))
  draw_top_item(350, "PWR", tpwr_text, value_color)
  draw_vline(392, 9, 42, line_color)
  local tx_col = value_color
  if tx_v > 0 and tx_v < 6.9 then tx_col = RED elseif tx_v > 0 and tx_v < 7.2 then tx_col = ORANGE end
  draw_top_item(432, "Tx", string.format("%.1fV", tx_v), tx_col)
  draw_small_battery(418, 48, 32, 10, tx_percent(tx_v), tx_col)

  draw_battery_ring(X(70), Y(112), batp, capa, value_color)
  lcd.drawText(X(70), Y(171), "BATTERY REMAINING", CENTER + VCENTER + SMLSIZE + WHITE)

  draw_box(10, 181, 158, 50, RED)
  lcd.drawText(X(50), Y(189), "PACK", CENTER + VCENTER + TINY + WHITE)
  lcd.drawText(X(128), Y(189), "CELL", CENTER + VCENTER + TINY + WHITE)
  lcd.drawText(X(50), Y(200), string.format("%.1fV", pack_v), CENTER + VCENTER + TINY + BOLD + value_color)
  lcd.drawText(X(128), Y(200), string.format("%.2fV", cell_v), CENTER + VCENTER + TINY + BOLD + value_color)
  draw_hline(20, 207, 138, line_color)
  lcd.drawText(X(50), Y(216), "CURR", CENTER + VCENTER + TINY + WHITE)
  lcd.drawText(X(128), Y(216), "POWER", CENTER + VCENTER + TINY + WHITE)
  lcd.drawText(X(50), Y(227), string.format("%.1fA", curr), CENTER + VCENTER + TINY + BOLD + value_color)
  lcd.drawText(X(128), Y(227), string.format("%dW", math.floor(watts + 0.5)), CENTER + VCENTER + TINY + BOLD + value_color)

  lcd.drawText(X(240), Y(70), "GPS SPEED", CENTER + VCENTER + WHITE)
  lcd.drawText(X(240), Y(112), string.format("%d", math.floor(gspd + 0.5)), CENTER + VCENTER + DBLSIZE + BOLD + value_color)
  lcd.drawText(X(240), Y(148), "km/h", CENTER + VCENTER + MIDSIZE + WHITE)

  update_model_image(widget.options.ShowImage)
  if widget.options.ShowImage == 1 then
    if model_pic_obj then
      lcd.drawBitmap(model_pic_obj, X(188), Y(164))
    elseif default_pic_obj then
      lcd.drawBitmap(default_pic_obj, X(188), Y(164))
    end
  end

  draw_box(338, 60, 132, 76, CYAN_COL)
  if rssi2 == 0 then
    lcd.drawText(X(378), Y(73), "1RSS", CENTER + VCENTER + SMLSIZE + WHITE)
    lcd.drawText(X(438), Y(73), "TRSS", CENTER + VCENTER + SMLSIZE + WHITE)
    lcd.drawText(X(378), Y(88), string.format("%ddB", math.floor(rssi1 + 0.5)), CENTER + VCENTER + SMLSIZE + value_color)
    lcd.drawText(X(438), Y(88), string.format("%ddB", math.floor(trss + 0.5)), CENTER + VCENTER + SMLSIZE + value_color)
    draw_hline(348, 101, 112, line_color)
    lcd.drawText(X(378), Y(114), "RQly", CENTER + VCENTER + SMLSIZE + WHITE)
    lcd.drawText(X(438), Y(114), "TQly", CENTER + VCENTER + SMLSIZE + WHITE)
    lcd.drawText(X(378), Y(128), string.format("%d%%", math.floor(lq + 0.5)), CENTER + VCENTER + SMLSIZE + value_color)
    lcd.drawText(X(438), Y(128), string.format("%d%%", math.floor(tqly + 0.5)), CENTER + VCENTER + SMLSIZE + value_color)
  else
    lcd.drawText(X(378), Y(73), "1RSS", CENTER + VCENTER + SMLSIZE + WHITE)
    lcd.drawText(X(438), Y(73), "2RSS", CENTER + VCENTER + SMLSIZE + WHITE)
    lcd.drawText(X(378), Y(88), string.format("%ddB", math.floor(rssi1 + 0.5)), CENTER + VCENTER + SMLSIZE + value_color)
    lcd.drawText(X(438), Y(88), string.format("%ddB", math.floor(rssi2 + 0.5)), CENTER + VCENTER + SMLSIZE + value_color)
    draw_hline(348, 101, 112, line_color)
    lcd.drawText(X(378), Y(114), "TRSS", CENTER + VCENTER + SMLSIZE + WHITE)
    lcd.drawText(X(438), Y(114), "TQly", CENTER + VCENTER + SMLSIZE + WHITE)
    lcd.drawText(X(378), Y(128), string.format("%ddB", math.floor(trss + 0.5)), CENTER + VCENTER + SMLSIZE + value_color)
    lcd.drawText(X(438), Y(128), string.format("%d%%", math.floor(tqly + 0.5)), CENTER + VCENTER + SMLSIZE + value_color)
  end

  draw_box(338, 142, 132, 83, CYAN_COL)
  if not gps_ok then
    draw_icon("sat", 346, 147)
    lcd.drawText(X(405), Y(154), "NO GPS", CENTER + VCENTER + WHITE)
    draw_hline(348, 164, 112, line_color)
    draw_icon("alt", 346, 168)
    lcd.drawText(X(378), Y(175), "ALT", LEFT + VCENTER + WHITE)
    lcd.drawText(X(462), Y(175), string.format("%dm", math.floor(alt + 0.5)), RIGHT + VCENTER + MIDSIZE + value_color)
    draw_hline(348, 185, 112, line_color)
    draw_icon("hdg", 346, 189)
    lcd.drawText(X(378), Y(196), "HDG", LEFT + VCENTER + WHITE)
    lcd.drawText(X(462), Y(196), "--", RIGHT + VCENTER + MIDSIZE + DARKGREY)
    draw_hline(348, 206, 112, line_color)
    draw_icon("home", 346, 208)
    lcd.drawText(X(378), Y(216), "DIST HOME", LEFT + VCENTER + SMLSIZE + WHITE)
    lcd.drawText(X(462), Y(216), "--", RIGHT + VCENTER + SMLSIZE + DARKGREY)
  else
    draw_icon("sat", 346, 147)
    lcd.drawText(X(378), Y(154), "SATS", LEFT + VCENTER + WHITE)
    lcd.drawText(X(462), Y(154), string.format("%d", math.floor(sats + 0.5)), RIGHT + VCENTER + MIDSIZE + value_color)
    draw_hline(348, 164, 112, line_color)
    draw_icon("alt", 346, 168)
    lcd.drawText(X(378), Y(175), "ALT", LEFT + VCENTER + WHITE)
    lcd.drawText(X(462), Y(175), string.format("%dm", math.floor(alt + 0.5)), RIGHT + VCENTER + MIDSIZE + value_color)
    draw_hline(348, 185, 112, line_color)
    draw_icon("hdg", 346, 189)
    lcd.drawText(X(378), Y(196), "HDG", LEFT + VCENTER + WHITE)
    lcd.drawText(X(462), Y(196), string.format("%d°", math.floor(hdg + 0.5)), RIGHT + VCENTER + MIDSIZE + value_color)
    draw_hline(348, 206, 112, line_color)
    draw_icon("home", 346, 208)
    lcd.drawText(X(378), Y(216), "DIST HOME", LEFT + VCENTER + SMLSIZE + WHITE)
    lcd.drawText(X(462), Y(216), string.format("%dm", math.floor(dist + 0.5)), RIGHT + VCENTER + SMLSIZE + value_color)
  end

  local mins = math.floor(armed_seconds / 60)
  local secs = armed_seconds % 60
  draw_box(9, 234, 462, 34, line_color)
  draw_icon("batt", 18, 240)
  draw_small_battery(18, 258, 18, 6, batp, (batp < 20 and RED or (batp < 40 and ORANGE or value_color)))
  lcd.drawText(X(52), Y(243), "USED", LEFT + VCENTER + SMLSIZE + WHITE)
  lcd.drawText(X(52), Y(256), string.format("%dmAh", math.floor(capa + 0.5)), LEFT + VCENTER + SMLSIZE + value_color)
  draw_vline(122, 238, 26, line_color)
  draw_icon("bolt", 132, 240)
  lcd.drawText(X(166), Y(243), "MAX SPEED", LEFT + VCENTER + SMLSIZE + WHITE)
  lcd.drawText(X(166), Y(256), string.format("%dkm/h", math.floor(max_speed + 0.5)), LEFT + VCENTER + SMLSIZE + value_color)
  draw_vline(240, 238, 26, line_color)
  draw_icon("home", 250, 240)
  lcd.drawText(X(284), Y(243), "DIST HOME", LEFT + VCENTER + SMLSIZE + WHITE)
  lcd.drawText(X(284), Y(256), string.format("%dm", math.floor(dist + 0.5)), LEFT + VCENTER + SMLSIZE + value_color)
  draw_vline(342, 238, 26, line_color)
  draw_icon("stop", 352, 240)
  lcd.drawText(X(386), Y(243), "FLIGHT", LEFT + VCENTER + SMLSIZE + WHITE)
  lcd.drawText(X(386), Y(256), string.format("%02d:%02d", mins, secs), LEFT + VCENTER + SMLSIZE + value_color)
  draw_vline(422, 238, 26, line_color)
  draw_icon("clock", 427, 240)
  local dt = getDateTime()
  lcd.drawText(X(470), Y(263), string.format("%02d:%02d:%02d", dt.hour, dt.min, dt.sec), RIGHT + VCENTER + SMLSIZE + WHITE)
end

return {
  name = NAME,
  options = options,
  create = create,
  update = update,
  refresh = refresh,
  background = background
}
