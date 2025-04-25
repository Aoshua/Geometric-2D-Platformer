extends Node


func format_number_with_commas(num):
	var string_num = str(num)
	var mod = string_num.length() % 3
	var result = ""
	
	for i in range(0, string_num.length()):
		if i != 0 && (i - mod) % 3 == 0:
			result += ","
		result += string_num[i]
	
	return result
