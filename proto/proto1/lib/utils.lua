function table.last (t)
	return t[table.maxn(t)]
end

function math.clamp (value, min, max)
	return math.min(math.max(value,min),max)
end

