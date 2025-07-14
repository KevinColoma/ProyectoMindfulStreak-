import json

with open("report.json", "r") as f:
    data = json.load(f)

html = """
<html>
<head><title>Reporte de Complejidad Ciclomática</title></head>
<body>
<h1>Reporte de Complejidad Ciclomática</h1>
<table border="1" cellpadding="5" cellspacing="0">
<tr>
<th>Archivo</th><th>Función</th><th>Líneas</th><th>Complejidad</th><th>Parámetros</th>
</tr>
"""

for func in data.get("functions", []):
    html += f"<tr><td>{func['filename']}</td><td>{func['name']}</td><td>{func['length']}</td><td>{func['cyclomatic_complexity']}</td><td>{func['parameter_count']}</td></tr>"

html += "</table></body></html>"

with open("report.html", "w") as f:
    f.write(html)

print("Reporte HTML generado como report.html")
