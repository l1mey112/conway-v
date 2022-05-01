import math

struct VectorInt {
	x int
	y int
}

fn ruint(v f64)u8{
	return u8(math.round(v))
}

fn mapf(old_min f64, old_max f64, new_min f64, new_max f64, value f64)f64{
	return new_min + ((new_max-new_min)/(old_max-old_min)) * (math.clamp(value, old_min, old_max))
}