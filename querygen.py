# Редачить вот эти следующие переменные
table = "subscribers"
tableColumns = [
	"pub_id",
	"name",
	"surname",
	"street_id",
	"house",
	"apartment",
	"subs_date",
	"exp_date"
]
data = [
	[1, "a", "b", 1, 1, 1, "2020-10-10", "2022-11-11"],
	[1, "a", "b", 1, 1, 1, "2020-10-10", "2022-11-11"],
	[2, "a", "b", 9, 1, 1, "2020-10-10", "2022-11-11"],
	[2, "a", "b", 9, 1, 1, "2020-10-10", "2022-11-11"],
	[2, "a", "b", 9, 1, 1, "2020-10-10", "2022-11-11"]
]
updateFrom = 1
updateTo = 22

# Это вот трогать не надо
def simpleInsert(table, columns, data):
	with open("query.txt", "w", encoding="utf8") as file:
		for row in data:
			query = f"INSERT INTO {table} ("
			for coulmn in columns:
				query += f"{coulmn},"
			query = query[:-1]
			query += ") VALUES ("
			for item in row:
				if item == "NULL":
					query += "NULL,"
				elif type(item) is str:
					query += f"\"{item}\","
				elif type(item) is int or float:
					query += f"{item},"
			query = query[:-1]
			query += ");\n"
			file.write(query)
	print("Inserts have been successfully written to a file!")

def simpleUpdate(table, columns, data, a, b):
	with open("query.txt", "w", encoding="utf8") as file:
		for row, a in zip(data, range(a, b+1)):
			query = f"UPDATE {table}\nSET"
			for i in range(len(columns)):
				if row[i] == "NULL":
					query += "NULL,"
				elif type(row[i]) is str:
					query += f" {columns[i]} = \"{row[i]}\","
				elif type(row[i]) is int or float:
					query += f" {columns[i]} = {row[i]},"
			query = query[:-1]
			query += f"\nWHERE id = {a};\n\n"
			file.write(query)
	print("Updates have been successfully written to a file!")

options = ("Choose any option:\n"
		   "1. INSERT INTO\n"
		   "2. UPDATE\n")
match int(input(options)):
	case 1:
		simpleInsert(table, tableColumns, data)
	case 2:
		simpleUpdate(table, tableColumns, data, updateFrom, updateTo)
	case _:
		print("...and nothing happened...")