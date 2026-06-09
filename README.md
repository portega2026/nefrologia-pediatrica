# nefrologia-pediatr-ca
Todo sobre la disciplina Nefrologia Pediátrica

## Sincronización automática con GitHub

Este repositorio incluye `auto-sync.sh`, un watcher simple que detecta cambios en `index.html`, crea un commit y hace `push` al remoto `origin`.

### Uso

```bash
chmod +x auto-sync.sh
./auto-sync.sh
```

### Nota

Si vuelve a aparecer un conflicto al sincronizar, significa que ya hay cambios en GitHub que no están en tu copia local. En ese caso hay que hacer `git pull` antes de continuar.
