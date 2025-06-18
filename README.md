
---

## Requisitos
- Cuenta de AWS válida
- Claves de acceso (Access Key ID y Secret Access Key)

---

## Variables requeridas

El despliegue requiere dos variables sensibles para autenticar con AWS:

| Variable          | Descripción                        |
|------------------|------------------------------------|
| `aws_access_key` | Tu AWS Access Key ID               |
| `aws_secret_key` | Tu AWS Secret Access Key           |

---


### El siguiente comando pasando las claves de conexión a AWS es el siguiente:

```bash
terraform init

terraform apply -var="aws_access_key=TU_ACCESS_KEY" -var="aws_secret_key=TU_SECRET_KEY"
