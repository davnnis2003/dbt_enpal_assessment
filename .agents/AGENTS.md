# Project Rules and Conventions

- **SQL Capitalization**: All SQL reserved words, functions, and operators (including but not limited to `SELECT`, `FROM`, `WHERE`, `JOIN`, `ON`, `AND`, `OR`, `CASE`, `WHEN`, `THEN`, `ELSE`, `END`, `AS`, `CAST`, `MIN`, `MAX`, `LAG`, `OVER`, `PARTITION BY`, `ORDER BY`, `GROUP BY`) must always be capitalized.
- **SQL Aliasing**: Always use explicit `AS` aliases for all columns and tables/CTEs in SQL statements, even when the column name is unchanged (e.g. `table.column_name AS column_name`). Avoid using short, abbreviated aliases (like `dc`, `dct`, etc.); use full, explicit table or CTE names instead.


