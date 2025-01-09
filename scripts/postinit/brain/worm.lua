local function InsertTag(v)
    if not v.hunternotags then
      v.hunternotags = {"wormfriendly"}
    else
      table.insert(v.hunternotags, "wormfriendly")
    end
  end