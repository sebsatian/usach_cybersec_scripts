import pandas as pd

# Nombre del archivo
filename = 'mpec.xlsx'

# Definición de columnas
columns = [
    'Activo / Host',
    'EX (1-3)', 'AUTH (1-4)', 'L (1-5)', 'CI (1-5)', 'CO (1-5)', 'R (0-1)',
    'EX_n', 'AUTH_n', 'L_n', 'CI_n', 'CO_n', 'R_n',
    'Dim_Tecnica', 'Dim_Organizacional', 'P_act (%)', 'Nivel'
]

# Crear el escritor de Excel
writer = pd.ExcelWriter(filename, engine='xlsxwriter')
workbook = writer.book
worksheet = workbook.add_worksheet('MPEC')

# Formato encabezado
header_format = workbook.add_format({
    'bold': True,
    'text_wrap': True,
    'valign': 'vcenter',
    'align': 'center',
    'fg_color': '#D7E4BC',
    'border': 1
})

# Escribir encabezados
for col_num, value in enumerate(columns):
    worksheet.write(0, col_num, value, header_format)

# Prellenar filas con fórmulas
num_rows = 50
for row in range(1, num_rows + 1):
    r = row + 1  # fila real en Excel

    # 1. Normalización Min-Max
    worksheet.write_formula(row, 7,  f'=IF(B{r}<>"",(B{r}-1)/2,"")')  # EX_n
    worksheet.write_formula(row, 8,  f'=IF(C{r}<>"",(C{r}-1)/3,"")')  # AUTH_n
    worksheet.write_formula(row, 9,  f'=IF(D{r}<>"",(D{r}-1)/4,"")')  # L_n
    worksheet.write_formula(row, 10, f'=IF(E{r}<>"",(E{r}-1)/4,"")')  # CI_n
    worksheet.write_formula(row, 11, f'=IF(F{r}<>"",(F{r}-1)/4,"")')  # CO_n
    worksheet.write_formula(row, 12, f'=IF(G{r}<>"",G{r},"")')        # R_n

    # 2. Dimensiones ponderadas
    # Técnica (40%)
    worksheet.write_formula(
        row, 13,
        f'=IF(H{r}<>"",0.4*H{r}+0.2*I{r}+0.4*J{r},"")'
    )

    # Organizacional (60%)
    worksheet.write_formula(
        row, 14,
        f'=IF(K{r}<>"",0.6*K{r}+0.3*L{r}+0.1*M{r},"")'
    )

    # 3. Puntaje final MPEC
    worksheet.write_formula(
        row, 15,
        f'=IF(N{r}<>"",(0.4*N{r}+0.6*O{r})*100,"")'
    )

    # 4. Nivel de prioridad
    worksheet.write_formula(
        row, 16,
        f'=IF(P{r}="","",IF(P{r}>=90,"Crítica",IF(P{r}>=70,"Alta",IF(P{r}>=40,"Media","Baja"))))'
    )

# Ajuste de ancho de columnas
widths = [25, 10, 10, 10, 10, 10, 10, 8, 8, 8, 8, 8, 8, 14, 18, 12, 12]
for i, width in enumerate(widths):
    worksheet.set_column(i, i, width)

writer.close()
print(f"Archivo '{filename}' generado con éxito.")
